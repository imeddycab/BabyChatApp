//
//  InfoAmbientalView.swift
//  BabyChat
//
//  Created by eduardo caballero on 19/03/25.
//

import SwiftUI
import Charts
import Combine

struct InfoAmbientalView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var sensorDataManager = SensorDataManager()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Botón de regreso
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                            
                            Text("Información ambiental")
                                .foregroundColor(.black)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .cornerRadius(30)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    // Título
                    VStack {
                        Text("Ethan - Cuna")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        // Última actualización
                        if let ultimaFecha = sensorDataManager.ultimaActualizacion {
                            Text("Última actualización: \(formatearFecha(ultimaFecha))")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)
                        }
                        
                        // Selector de días
                        DaySelectorView(
                            diaSeleccionado: $sensorDataManager.diaSeleccionado,
                            diasDisponibles: sensorDataManager.diasDisponibles(),
                            mostrarSoloHoy: $sensorDataManager.mostrarSoloHoy
                        )
                        
                        // Nota sobre intervalos
                        Text(sensorDataManager.mostrarSoloHoy ?
                             "Mostrando datos del día actual (registros cada 10 minutos)" :
                             "Mostrando datos del \(formatearFechaCompleta(sensorDataManager.diaSeleccionado))")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        
                        // Tres gráficas independientes
                        VStack(spacing: 30) {
                            // Gráfica de TEMPERATURA
                            SingleChartView(
                                data: sensorDataManager.datosFiltradosParaVisualizacion(sensorDataManager.historialTemperatura),
                                title: "Temperatura",
                                unit: "°C",
                                color: .orange,
                                systemImage: "thermometer"
                            )
                            IndicatorView(
                                value: sensorDataManager.temperatura,
                                label: "TEMP",
                                unit: "°C",
                                color: .orange
                            )
                            
                            // Gráfica de HUMEDAD
                            SingleChartView(
                                data: sensorDataManager.datosFiltradosParaVisualizacion(sensorDataManager.historialHumedad),
                                title: "Humedad",
                                unit: "%",
                                color: .green,
                                systemImage: "humidity"
                            )
                            IndicatorView(
                                value: sensorDataManager.humedad,
                                label: "HUM",
                                unit: "%",
                                color: .green
                            )
                            
                            // Gráfica de GASES
                            SingleChartView(
                                data: sensorDataManager.datosFiltradosParaVisualizacion(sensorDataManager.historialGases),
                                title: "Gases",
                                unit: "ppa",
                                color: .blue,
                                systemImage: "wind"
                            )
                            IndicatorView(
                                value: sensorDataManager.voltaje_gas,
                                label: "GAS",
                                unit: "ppa",
                                color: .blue
                            )
                        }
                        .padding(.vertical)
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Datos ambientales en tiempo real
                    EnvironmentalDataView(
                        humedad: sensorDataManager.humedad,
                        temperatura: sensorDataManager.temperatura,
                        voltaje_gas: sensorDataManager.voltaje_gas
                    )
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Botón de recomendaciones
                    Button(action: {
                        sensorDataManager.generateRecommendation()
                    }) {
                        Text("Recomendación Inteligente")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.6), Color.green, Color.green.opacity(0.6), Color.green]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(30)
                            .padding(.vertical, 10)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Tarjeta de recomendación
                    VStack(alignment: .leading, spacing: 8) {
                        if sensorDataManager.isGeneratingRecommendation {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            if let recommendation = sensorDataManager.recommendation {
                                Text("Recomendación para \(sensorDataManager.babyName)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(recommendation)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    sensorDataManager.generateRecommendation()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Nueva recomendación")
                                            .fontWeight(.light)
                                    }
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(30)
                                }
                                .padding(.horizontal, 15)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.6), Color.green, Color.green.opacity(0.8), Color.green.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing).blur(radius: 20))
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0)
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 5)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            sensorDataManager.startListening()
        }
        .onDisappear {
            sensorDataManager.stopListening()
        }
        .navigationBarHidden(true)
    }
    
    private func formatearFecha(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: fecha)
    }
    
    private func formatearFechaCompleta(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: fecha)
    }
}

struct DaySelectorView: View {
    @Binding var diaSeleccionado: Date
    var diasDisponibles: [Date]
    @Binding var mostrarSoloHoy: Bool
    
    var body: some View {
        VStack {
            Toggle("Mostrar solo hoy", isOn: $mostrarSoloHoy)
                .padding(.horizontal)
                .toggleStyle(SwitchToggleStyle(tint: .green))
            
            if !mostrarSoloHoy {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(diasDisponibles, id: \.self) { dia in
                            Button(action: {
                                withAnimation {
                                    diaSeleccionado = dia
                                }
                            }) {
                                VStack {
                                    Text(dia.formatted(.dateTime.weekday(.abbreviated)))
                                        .font(.caption)
                                    Text(dia.formatted(.dateTime.day()))
                                        .font(.title3)
                                }
                                .frame(width: 50, height: 60)
                                .background(diaSeleccionado == dia ? Color.green : Color(.systemGray5))
                                .foregroundColor(diaSeleccionado == dia ? .white : .primary)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

struct SingleChartView: View {
    let data: [SensorHistorial]
    let title: String
    let unit: String
    let color: Color
    let systemImage: String
    
    @State private var plotWidth: CGFloat = 0
    private let minPointSpacing: CGFloat = 30
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                Spacer()
                Text("(\(unit))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                let totalWidthNeeded = CGFloat(data.count) * minPointSpacing
                
                ScrollView(.horizontal, showsIndicators: false) {
                    Chart {
                        ForEach(data) { punto in
                            LineMark(
                                x: .value("Hora", punto.fecha, unit: .minute),
                                y: .value(title, punto.valor)
                            )
                            .foregroundStyle(color)
                            .interpolationMethod(.catmullRom) // Cambiado a interpolación curvada
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            
                            PointMark(
                                x: .value("Hora", punto.fecha, unit: .minute),
                                y: .value(title, punto.valor)
                            )
                            .foregroundStyle(color)
                            .symbolSize(60)
                            .symbol {
                                Circle()
                                    .fill(color)
                                    .frame(width: 8, height: 8)
                                    .shadow(color: color.opacity(0.5), radius: 3)
                            }
                        }
                    }
                    .frame(width: totalWidthNeeded)
                    .animation(.easeInOut(duration: 0.5), value: data)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .hour)) { value in
                            AxisGridLine()
                            if value.as(Date.self) != nil {
                                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                Text("\(value.as(Double.self) ?? 0, specifier: "%.1f")")
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(height: 180)
        }
    }
}

struct IndicatorView: View {
    let value: Double
    let label: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text("\(value, specifier: "%.1f")\(unit)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct EnvironmentalDataView: View {
    var humedad: Double
    var temperatura: Double
    var voltaje_gas: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack {
                HStack {
                    Text("Humedad")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(humedad))%")
                        .foregroundColor(.green)
                }
                Text("El nivel de humedad del aire es óptimo.")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
            }
            VStack {
                HStack {
                    Text("Temperatura")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(temperatura))°")
                        .foregroundColor(.orange)
                }
                Text("El grado de temperatura de la habitación es óptima.")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
            }
            VStack {
                HStack {
                    Text("Gases")
                        .font(.headline)
                    Spacer()
                    Text("\(String(format: "%.2f", voltaje_gas)) ppa")
                        .foregroundColor(.blue)
                }
                Text("La concentración de gases en la habitación es segura.")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

class SensorDataManager: ObservableObject {
    @Published var temperatura: Double = 0
    @Published var humedad: Double = 0
    @Published var voltaje_gas: Double = 0
    @Published var historialTemperatura: [SensorHistorial] = []
    @Published var historialHumedad: [SensorHistorial] = []
    @Published var historialGases: [SensorHistorial] = []
    @Published var ultimaActualizacion: Date? = nil
    @Published var recommendation: String? = nil
    @Published var isGeneratingRecommendation = false
    @Published var diaSeleccionado: Date = Date()
    @Published var mostrarSoloHoy: Bool = true
    
    let babyName = "Ethan"
    
    private var cancellable: AnyCancellable?
    private let firebaseURL = "https://eddydemo-f3fa8-default-rtdb.firebaseio.com/usuarios/001/bebes/bb000/babymonitor/seguimiento.json"
    private let apiKey = "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"
    private let apiURL = "https://api.groq.com/openai/v1/chat/completions"
    
    func startListening() {
        guard let url = URL(string: firebaseURL) else {
            print("Error: URL inválida")
            return
        }
        
        cancellable = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in
                URLSession.shared.dataTaskPublisher(for: url)
                    .map { data, response in
                        print("Respuesta cruda: \(String(data: data, encoding: .utf8) ?? "No se pudo decodificar")")
                        return data
                    }
                    .decode(type: SeguimientoData.self, decoder: JSONDecoder())
                    .mapError { error -> Error in
                        print("Error detallado: \(error)")
                        if let decodingError = error as? DecodingError {
                            print("DecodingError details: \(decodingError)")
                        }
                        return error
                    }
                    .catch { error -> Just<SeguimientoData> in
                        print("Error al decodificar: \(error.localizedDescription)")
                        return Just(SeguimientoData(
                            historial_sensores: HistorialSensores(
                                gases: [:],
                                humedad: [:],
                                temperatura: [:]
                            ),
                            tiemporeal_sensores: RealTimeSensorData(
                                temperatura: SensorValue(fechahora: "", registro: 0),
                                humedad: SensorValue(fechahora: "", registro: 0),
                                gases: SensorValue(fechahora: "", registro: 0)
                        )))
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] seguimientoData in
                self?.temperatura = seguimientoData.tiemporeal_sensores.temperatura.registro
                self?.humedad = seguimientoData.tiemporeal_sensores.humedad.registro
                self?.voltaje_gas = seguimientoData.tiemporeal_sensores.gases.registro
                self?.procesarHistorial(seguimientoData.historial_sensores)
            }
    }
    
    func datosFiltradosParaVisualizacion(_ datos: [SensorHistorial]) -> [SensorHistorial] {
        if mostrarSoloHoy {
            return datosParaDia(datos, dia: Date())
        } else {
            return datosParaDia(datos, dia: diaSeleccionado)
        }
    }
    
    func datosParaDia(_ datos: [SensorHistorial], dia: Date) -> [SensorHistorial] {
        let calendar = Calendar.current
        return datos.filter { calendar.isDate($0.fecha, inSameDayAs: dia) }
    }
    
    func diasDisponibles() -> [Date] {
        var dias: Set<Date> = Set()
        let calendar = Calendar.current
        
        [historialTemperatura, historialHumedad, historialGases].forEach { datos in
            datos.forEach { punto in
                let dia = calendar.startOfDay(for: punto.fecha)
                dias.insert(dia)
            }
        }
        
        return Array(dias).sorted(by: { $0 > $1 })
    }
    
    func generateRecommendation() {
        isGeneratingRecommendation = true
        recommendation = nil
        
        let currentData = """
        Datos actuales:
        - Temperatura: \(String(format: "%.1f", temperatura))°C
        - Humedad: \(String(format: "%.1f", humedad))%
        - Gases: \(String(format: "%.2f", voltaje_gas)) ppa
        """
        
        let historicalData = """
        Tendencias recientes:
        - Temperatura: \(getTrendDescription(for: historialTemperatura))
        - Humedad: \(getTrendDescription(for: historialHumedad))
        - Gases: \(getTrendDescription(for: historialGases))
        """
        
        let prompt = """
        Eres un experto en cuidado infantil y monitoreo ambiental. Analiza los siguientes datos del monitor del cuarto del bebé \(babyName) y proporciona una recomendación detallada (100 palabras máximo) para los padres:
        
        \(currentData)
        
        \(historicalData)
        
        Considera:
        1. Condiciones actuales del ambiente
        2. Tendencias recientes
        3. Posibles riesgos o mejoras
        4. Acciones recomendadas
        5. Horarios óptimos para ventilación
        
        Responde directamente con la recomendación, sin introducciones.
        """
        
        let requestBody: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "temperature": 0.7,
            "max_completion_tokens": 300,
            "top_p": 1,
            "messages": [["role": "user", "content": prompt]]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            recommendation = "Error al preparar la solicitud"
            isGeneratingRecommendation = false
            return
        }
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isGeneratingRecommendation = false
                
                if let error = error {
                    self.recommendation = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let message = choices.first?["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    self.recommendation = "No se pudo interpretar la respuesta"
                    return
                }
                
                self.recommendation = content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }.resume()
    }
    
    private func getTrendDescription(for data: [SensorHistorial]) -> String {
        guard data.count >= 2 else { return "datos insuficientes" }
        
        let lastValue = data[data.count - 1].valor
        let previousValue = data[data.count - 2].valor
        let difference = lastValue - previousValue
        let percentChange = (difference / previousValue) * 100
        
        if abs(percentChange) < 2 {
            return "estable (\(String(format: "%.1f", lastValue)))"
        } else if percentChange > 0 {
            return "en aumento (\(String(format: "%.1f", previousValue)) → \(String(format: "%.1f", lastValue)))"
        } else {
            return "en descenso (\(String(format: "%.1f", previousValue)) → \(String(format: "%.1f", lastValue)))"
        }
    }
    
    private func procesarHistorial(_ historial: HistorialSensores) {
        let nuevosTemperatura = historial.temperatura.map { (fecha, valor) in
            SensorHistorial(fecha: convertirFecha(fecha), valor: valor)
        }.sorted { $0.fecha < $1.fecha }
        
        let nuevosHumedad = historial.humedad.map { (fecha, valor) in
            SensorHistorial(fecha: convertirFecha(fecha), valor: valor)
        }.sorted { $0.fecha < $1.fecha }
        
        let nuevosGases = historial.gases.map { (fecha, valor) in
            SensorHistorial(fecha: convertirFecha(fecha), valor: valor)
        }.sorted { $0.fecha < $1.fecha }
        
        if nuevosTemperatura != historialTemperatura {
            historialTemperatura = nuevosTemperatura
        }
        
        if nuevosHumedad != historialHumedad {
            historialHumedad = nuevosHumedad
        }
        
        if nuevosGases != historialGases {
            historialGases = nuevosGases
        }
        
        if let ultimoTemperatura = historialTemperatura.last?.fecha,
           let ultimoHumedad = historialHumedad.last?.fecha,
           let ultimoGases = historialGases.last?.fecha {
            
            let fechas = [ultimoTemperatura, ultimoHumedad, ultimoGases]
            ultimaActualizacion = fechas.max()
        }
    }
    
    private func convertirFecha(_ fechaString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy_HH:mm:ss"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.date(from: fechaString) ?? Date()
    }
    
    func stopListening() {
        cancellable?.cancel()
    }
}

struct SeguimientoData: Codable {
    let historial_sensores: HistorialSensores
    let tiemporeal_sensores: RealTimeSensorData
}

struct HistorialSensores: Codable {
    let gases: [String: Double]
    let humedad: [String: Double]
    let temperatura: [String: Double]
}

struct RealTimeSensorData: Codable {
    let temperatura: SensorValue
    let humedad: SensorValue
    let gases: SensorValue
}

struct SensorValue: Codable {
    let fechahora: String
    let registro: Double
}

struct SensorHistorial: Identifiable, Equatable {
    let id = UUID()
    let fecha: Date
    let valor: Double
    
    static func == (lhs: SensorHistorial, rhs: SensorHistorial) -> Bool {
        lhs.fecha == rhs.fecha && lhs.valor == rhs.valor
    }
}

struct InfoAmbientalView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = SensorDataManager()
        
        // Datos de ejemplo para varios días
        let calendar = Calendar.current
        let hoy = Date()
        let ayer = calendar.date(byAdding: .day, value: -1, to: hoy)!
        let anteayer = calendar.date(byAdding: .day, value: -2, to: hoy)!
        
        manager.historialTemperatura = [
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -2, to: anteayer)!, valor: 21),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -1, to: anteayer)!, valor: 21.5),
            SensorHistorial(fecha: anteayer, valor: 22),
            
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -5, to: ayer)!, valor: 22.5),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -3, to: ayer)!, valor: 23),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -1, to: ayer)!, valor: 22),
            
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -3, to: hoy)!, valor: 22),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -2, to: hoy)!, valor: 23),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -1, to: hoy)!, valor: 23.5),
            SensorHistorial(fecha: hoy, valor: 24)
        ]
        
        manager.historialHumedad = [
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -2, to: anteayer)!, valor: 60),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -1, to: anteayer)!, valor: 62),
            SensorHistorial(fecha: anteayer, valor: 63),
            
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -5, to: ayer)!, valor: 64),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -3, to: ayer)!, valor: 66),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -1, to: ayer)!, valor: 65),
            
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -3, to: hoy)!, valor: 65),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -2, to: hoy)!, valor: 68),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -1, to: hoy)!, valor: 70),
            SensorHistorial(fecha: hoy, valor: 72)
        ]
        
        manager.historialGases = [
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -2, to: anteayer)!, valor: 1.5),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -1, to: anteayer)!, valor: 1.6),
            SensorHistorial(fecha: anteayer, valor: 1.7),
            
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -5, to: ayer)!, valor: 1.8),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -3, to: ayer)!, valor: 1.9),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -1, to: ayer)!, valor: 2.0),
            
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -3, to: hoy)!, valor: 1.8),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -2, to: hoy)!, valor: 2.0),
            SensorHistorial(fecha: calendar.date(byAdding: .hour, value: -1, to: hoy)!, valor: 2.2),
            SensorHistorial(fecha: hoy, valor: 2.5)
        ]
        
        manager.temperatura = 24
        manager.humedad = 72
        manager.voltaje_gas = 2.5
        manager.recommendation = "La temperatura actual de 24°C es ideal para el bebé. La humedad del 72% está en el rango óptimo. Los niveles de gases son seguros. Recomendamos mantener la habitación ventilada por las mañanas cuando la temperatura exterior es fresca."
        manager.mostrarSoloHoy = false
        
        return InfoAmbientalView()
            .environmentObject(manager)
    }
}
