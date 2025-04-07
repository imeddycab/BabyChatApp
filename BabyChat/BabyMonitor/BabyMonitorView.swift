import SwiftUI
import Combine
@preconcurrency import WebKit
import UserNotifications

struct MonitorView: View {
    @State private var isCameraOn = true
    @State private var temperatura: Double = 0
    @State private var humedad: Double = 0
    @State private var voltaje_gas: Double = 0
    @State private var cancellable: AnyCancellable?
    @State private var changeBaby = false
    @State private var observaciones: String = "¿Quieres que analicemos el ambiente?"
    @State private var isLoadingObservations = false
    @State private var showVideoError = false
    @State private var isFullScreen = false
    @State private var lastUpdateTime: Date = Date()
    @State private var isDisconnected = false
    @State private var connectionTimer: Timer?
    
    // URLs
    let firebaseURL = "https://eddydemo-f3fa8-default-rtdb.firebaseio.com/usuarios/001/bebes/bb000/babymonitor/seguimiento/tiemporeal_sensores.json"
    let videoStreamURL = "https://asp-dominant-yeti.ngrok-free.app/video"
    let apiKey = "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"
    let apiURL = "https://api.groq.com/openai/v1/chat/completions"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        changeBaby = true
                    }) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 45, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.top, 10)
                    }
                    
                    Text("BabyMonitor")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                        .padding(.top, 10)
                    
                    NavigationLink(destination: NotificacionesMonitorView()) {
                        Image(systemName: "bell.circle.fill")
                            .font(.system(size: 45, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Ethan")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $isCameraOn)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .onChange(of: isCameraOn) { oldValue, newValue in
                                // Aquí puedes manejar los cambios, ahora con acceso al valor anterior (oldValue) y el nuevo valor (newValue)
                                print("La cámara cambió de \(oldValue) a \(newValue)")
                            }
                    }
                    
                    // Vista de video
                    VStack {
                        if isCameraOn {
                            ZStack(alignment: .topTrailing) {
                                VideoPlayerWebView(videoURL: videoStreamURL)
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .cornerRadius(15)
                                    .shadow(radius: 5)

                                Button(action: {
                                    isFullScreen = true
                                }) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .font(.title)
                                        .padding(10)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                        .padding(5)
                                }
                            }
                        } else {
                            CameraOffView()
                        }
                    }
                    .fullScreenCover(isPresented: $isFullScreen) {
                        FullScreenVideoView(videoURL: videoStreamURL, isFullScreen: $isFullScreen)
                            .transition(.opacity.combined(with: .scale))
                    }

                    Divider()
                    
                    Text("Parámetros Ambientales")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    VStack(alignment: .leading, spacing: 5) {
                        SensorItem(nombre: "Humedad", valor: "\(Int(humedad))%", color: .green)
                        SensorItem(nombre: "Temperatura", valor: "\(Int(temperatura))°C", color: .orange)
                        SensorItem(nombre: "Gases", valor: "\(String(format: "%.2f", voltaje_gas)) ppa", color: .blue)
                    }
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: InfoAmbientalView()) {
                            Text("Ver Detalle Ambiental →")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.green)
                                .cornerRadius(30)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    
                    Divider()
                    
                    Text("Observaciones")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if isLoadingObservations {
                        ProgressView()
                            .frame(height: 50)
                    } else {
                        Text(observaciones)
                            .frame(minHeight: 50)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        getObservationsFromAI()
                    }) {
                        Text("Analizar Datos")
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(30)
                    }
                    .padding(.vertical, 5)
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 5)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 90)
            .sheet(isPresented: $changeBaby) {
                CambiarMonitorView()
                    .padding(.vertical, 20)
                    .background(Color(.green).opacity(0.6).blur(radius: 50))
                    .presentationCornerRadius(30)
            }
        }
        .onAppear {
            startListeningToFirebase()
            setupConnectionTimer()
            requestNotificationPermission()
        }
        .onDisappear {
            cancellable?.cancel()
            connectionTimer?.invalidate()
        }
        .overlay(
            isDisconnected ? DisconnectionBanner() : nil,
            alignment: .top
        )
    }
    
    // Banner de desconexión
    struct DisconnectionBanner: View {
        var body: some View {
            Text("Monitor desconectado")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: 1)
        }
    }
    
    // Vista personalizada para el reproductor de video
    struct VideoPlayerWebView: UIViewRepresentable {
        let videoURL: String

        class Coordinator: NSObject, WKUIDelegate {
            var parent: VideoPlayerWebView

            init(parent: VideoPlayerWebView) {
                self.parent = parent
            }

            func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
                print("JS Alert: \(message)")
                completionHandler()
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }

        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.uiDelegate = context.coordinator
            webView.isOpaque = false
            webView.backgroundColor = .black
            webView.scrollView.isScrollEnabled = false

            if let url = URL(string: videoURL) {
                var request = URLRequest(url: url)
                request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")
                webView.load(request)
            }

            return webView
        }

        func updateUIView(_ webView: WKWebView, context: Context) {}
    }
    
    // Vista cuando hay error en el video
    struct VideoErrorView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.red.opacity(0.3))
                    .frame(height: 150)
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                    Text("Error al cargar el video")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    // Vista cuando la cámara está apagada
    struct CameraOffView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 150)
                VStack {
                    Image(systemName: "video.slash.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                    Text("Cámara apagada")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    struct FullScreenVideoView: View {
        let videoURL: String
        @Binding var isFullScreen: Bool

        var body: some View {
            ZStack(alignment: .topTrailing) {
                VideoPlayerWebView(videoURL: videoURL)
                    .edgesIgnoringSafeArea(.all)
                
                Button(action: {
                    isFullScreen = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding()
                }
            }
            .background(Color.black)
        }
    }
    
    // Solicitar permiso para notificaciones
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Permiso para notificaciones concedido")
            } else if let error = error {
                print("Error al solicitar permiso: \(error.localizedDescription)")
            }
        }
    }
    
    // Configurar el temporizador de verificación de conexión
    func setupConnectionTimer() {
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdateTime)
            
            if timeSinceLastUpdate > 60 && !isDisconnected {
                isDisconnected = true
                sendDisconnectionNotification()
            } else if timeSinceLastUpdate <= 60 && isDisconnected {
                isDisconnected = false
                sendReconnectionNotification()
            }
        }
    }
    
    // Notificación de desconexión
    func sendDisconnectionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Monitor desconectado"
        content.body = "Es posible que el monitor se haya desconectado de la red. Te notificaremos cuando vuelva la conexión."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // Notificación de reconexión
    func sendReconnectionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Conexión restablecida"
        content.body = "Se restableció la conexión del monitor."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func getObservationsFromAI() {
        isLoadingObservations = true
        
        let prompt = """
        Basado en estos datos del monitor del bebé:
        - Temperatura: \(Int(temperatura))°C
        - Humedad: \(Int(humedad))%
        - Nivel de gases: \(String(format: "%.2f", voltaje_gas)) ppa
        
        Proporciona una observación concisa (máximo 40 palabras) sobre el ambiente del cuarto del bebé. 
        Sé específico y da recomendaciones si es necesario.
        Responde directamente con la observación, sin introducción.
        """
        
        let requestBody: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "temperature": 0.3,
            "max_completion_tokens": 100,
            "top_p": 1,
            "messages": [["role": "user", "content": prompt]]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            observaciones = "Error al preparar la solicitud"
            isLoadingObservations = false
            return
        }
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoadingObservations = false
                
                if let error = error {
                    observaciones = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let message = choices.first?["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    observaciones = "No se pudo interpretar la respuesta"
                    return
                }
                
                observaciones = content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }.resume()
    }
    
    func startListeningToFirebase() {
        guard let url = URL(string: firebaseURL) else {
            print("Error: URL inválida")
            return
        }
        
        cancellable = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in
                URLSession.shared.dataTaskPublisher(for: url)
                    .map(\.data)
                    .decode(type: RealTimeSensorData.self, decoder: JSONDecoder())
                    .catch { error -> Just<RealTimeSensorData> in
                        print("Error al decodificar: \(error.localizedDescription)")
                        return Just(RealTimeSensorData(
                            temperatura: SensorValue(fechahora: "", registro: 0),
                            humedad: SensorValue(fechahora: "", registro: 0),
                            gases: SensorValue(fechahora: "", registro: 0)
                        ))
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { sensorData in
                print("Datos recibidos - Temp: \(sensorData.temperatura.registro), Hum: \(sensorData.humedad.registro), Gas: \(sensorData.gases.registro)")
                self.humedad = sensorData.humedad.registro
                self.temperatura = sensorData.temperatura.registro
                self.voltaje_gas = sensorData.gases.registro
                self.lastUpdateTime = Date() // Actualizar el tiempo de la última actualización
            })
    }
}

struct SensorItem: View {
    var nombre: String
    var valor: String
    var color: Color

    var body: some View {
        HStack {
            Text(nombre + ":")
            Spacer()
            Text(valor)
                .foregroundColor(color)
        }
        .font(.subheadline)
    }
}

// Vista de previsualización
#Preview {
    MonitorView()
}
