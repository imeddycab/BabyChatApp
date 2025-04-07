//
//  ExportDataView.swift
//  BabyChat
//
//  Created by eduardo caballero on 25/03/25.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ExportDataView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingShareSheet = false
    @State private var showingPreview = false
    @State private var tempPDFURL: URL?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var previewData: Data?
    
    // Opciones de exportación
    @State private var exportGrowthData = true
    @State private var exportChatHistory = true
    @State private var exportMonitorData = false
    @State private var exportSavedArticles = false
    @State private var exportFormat = 0 // 0: PDF, 1: CSV, 2: JSON
    
    // Datos de seguimiento
    @State private var pesoRegistros: [PesoRegistro] = []
    @State private var estaturaRegistros: [EstaturaRegistro] = []
    @State private var imcRegistros: [IMCRegistro] = []
    
    // Datos de bebés y selección
    @State private var selectedBaby: String = "Ethan"
    private let babyData: [String: (name: String, birthDate: String, gender: String, parentName: String, parentEmail: String)] = [
        "Ethan": (name: "Ethan Islas", birthDate: "18/10/2024", gender: "Masculino", parentName: "Emily Islas", parentEmail: "emily@example.com"),
        "Sofia": (name: "Sofia García", birthDate: "15/05/2023", gender: "Femenino", parentName: "Carlos García", parentEmail: "carlos@example.com"),
        "Lucas": (name: "Lucas Martínez", birthDate: "22/01/2024", gender: "Masculino", parentName: "Ana Martínez", parentEmail: "ana@example.com")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Botón de regreso
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Exportar datos")
                                .foregroundColor(.black)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "xmark")
                                .foregroundColor(.purple)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color(.systemGray6))
                        .cornerRadius(30)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                VStack(spacing: 20) {
                    // Contenido principal
                    VStack(spacing: 15) {
                        // Selector de bebé
                        HStack {
                            Text("Seleccionar bebé:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Picker("Bebé", selection: $selectedBaby) {
                                ForEach(Array(babyData.keys.sorted()), id: \.self) { key in
                                    Text(babyData[key]?.name ?? key).tag(key)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(60)
                        }
                        .padding(.horizontal)
                        
                        Text("Datos de \(babyData[selectedBaby]?.name ?? selectedBaby)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Selecciona qué datos deseas exportar:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Opciones de exportación
                        VStack(spacing: 10) {
                            Toggle("Datos de crecimiento (peso, estatura, IMC)", isOn: $exportGrowthData)
                            Toggle("Historial de chats", isOn: $exportChatHistory)
                            Toggle("Datos del monitor ambiental", isOn: $exportMonitorData)
                            Toggle("Artículos guardados", isOn: $exportSavedArticles)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        
                        // Selector de formato
                        Picker("Formato de exportación", selection: $exportFormat) {
                            Text("PDF").tag(0)
                            Text("CSV").tag(1)
                            Text("JSON").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Información del bebé seleccionado
                        if let babyInfo = babyData[selectedBaby] {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Información del bebé:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("• Nombre: \(babyInfo.name)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("• Fecha de nacimiento: \(babyInfo.birthDate)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("• Género: \(babyInfo.gender)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("• Padre/Madre: \(babyInfo.parentName)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                        
                        // Botones de acción
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            VStack(spacing: 15) {
                                // Botón de vista previa
                                Button(action: {
                                    generatePreview()
                                }) {
                                    HStack {
                                        Image(systemName: "eye.fill")
                                        Text("Vista Previa")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(30)
                                }
                                
                                // Botón de exportar
                                Button(action: {
                                    generateAndShareFile()
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Compartir Archivo")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(30)
                                }
                                
                                // Descriptive Text
                                Text("Recuerde que exportar los datos de los bebés que agregó a su cuenta es una opción para compartirlos con sus contactos de confianza. Evite exponer sus datos personales si no es necesario hacerlo.")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                                    .padding(.vertical)
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingPreview) {
                if let previewData = previewData {
                    VStack {
                        if exportFormat == 0 {
                            PDFPreviewView(pdfData: previewData)
                                .edgesIgnoringSafeArea(.all)
                        } else {
                            TextPreviewView(text: String(data: previewData, encoding: .utf8) ?? "No se pudo generar la vista previa")
                        }
                        
                        HStack {
                            Button(action: {
                                showingPreview = false
                            }) {
                                Text("Cerrar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(30)
                            }
                            
                            Button(action: {
                                showingPreview = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    generateAndShareFile()
                                }
                            }) {
                                Text("Compartir")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(30)
                            }
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = tempPDFURL {
                    ActivityViewController(activityItems: [url])
                        .onDisappear {
                            cleanupTempFile()
                        }
                }
            }
            .onChange(of: selectedBaby) { _ in
                loadTrackingData()
            }
            .onAppear {
                loadTrackingData()
            }
        }
    }
    
    private func loadTrackingData() {
        // Cargar datos de peso
        if let data = UserDefaults.standard.data(forKey: "pesoRegistros_\(selectedBaby)"),
           let decoded = try? JSONDecoder().decode([PesoRegistro].self, from: data) {
            pesoRegistros = decoded.sorted { $0.fecha > $1.fecha }
        } else {
            pesoRegistros = []
        }
        
        // Cargar datos de estatura
        if let data = UserDefaults.standard.data(forKey: "estaturaRegistros_\(selectedBaby)"),
           let decoded = try? JSONDecoder().decode([EstaturaRegistro].self, from: data) {
            estaturaRegistros = decoded.sorted { $0.fecha > $1.fecha }
        } else {
            estaturaRegistros = []
        }
        
        // Cargar datos de IMC
        if let data = UserDefaults.standard.data(forKey: "imcRegistros_\(selectedBaby)"),
           let decoded = try? JSONDecoder().decode([IMCRegistro].self, from: data) {
            imcRegistros = decoded.sorted { $0.fecha > $1.fecha }
        } else {
            imcRegistros = []
        }
    }
    
    private func generatePreview() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data: Data
                
                switch exportFormat {
                case 0: // PDF
                    data = try generatePDFData()
                case 1: // CSV
                    data = try generateCSVData()
                case 2: // JSON
                    data = try generateJSONData()
                default:
                    throw ExportError.unsupportedFormat
                }
                
                DispatchQueue.main.async {
                    self.previewData = data
                    self.isLoading = false
                    self.showingPreview = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    private func generateAndShareFile() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fileURL: URL
                
                switch exportFormat {
                case 0: // PDF
                    let data = try generatePDFData()
                    fileURL = try saveTempFile(data: data, extension: "pdf")
                case 1: // CSV
                    let data = try generateCSVData()
                    fileURL = try saveTempFile(data: data, extension: "csv")
                case 2: // JSON
                    let data = try generateJSONData()
                    fileURL = try saveTempFile(data: data, extension: "json")
                default:
                    throw ExportError.unsupportedFormat
                }
                
                DispatchQueue.main.async {
                    self.tempPDFURL = fileURL
                    self.isLoading = false
                    self.showingShareSheet = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    private func generatePDFData() throws -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "BabyChat",
            kCGPDFContextAuthor: "BabyChat App",
            kCGPDFContextTitle: "Datos de \(selectedBaby) - \(Date().formatted(date: .abbreviated, time: .omitted))"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let babyInfo = babyData[selectedBaby] ?? (name: selectedBaby, birthDate: "", gender: "", parentName: "", parentEmail: "")
        
        return renderer.pdfData { context in
            var yPosition: CGFloat = 50
            
            // Página 1: Datos básicos
            context.beginPage()
            
            // Título
            let title = "Datos de \(babyInfo.name)"
            drawText(title, in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 30),
                     font: .boldSystemFont(ofSize: 20), color: .purple)
            yPosition += 40
            
            // Información del bebé
            drawText("Información del bebé", in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 20),
                     font: .boldSystemFont(ofSize: 16), color: .black)
            yPosition += 25
            
            drawText("• Fecha de nacimiento: \(babyInfo.birthDate)",
                     in: CGRect(x: 60, y: yPosition, width: pageWidth - 120, height: 20),
                     font: .systemFont(ofSize: 12), color: .black)
            yPosition += 20
            
            drawText("• Género: \(babyInfo.gender)",
                     in: CGRect(x: 60, y: yPosition, width: pageWidth - 120, height: 20),
                     font: .systemFont(ofSize: 12), color: .black)
            yPosition += 20
            
            drawText("• Padre/Madre: \(babyInfo.parentName)",
                     in: CGRect(x: 60, y: yPosition, width: pageWidth - 120, height: 20),
                     font: .systemFont(ofSize: 12), color: .black)
            yPosition += 30
            
            // Fecha de exportación
            let dateString = "Exportado el \(Date().formatted(date: .complete, time: .shortened))"
            drawText(dateString, in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 20),
                     font: .systemFont(ofSize: 10), color: .gray)
            yPosition += 30
            
            // Sección de datos de crecimiento
            if exportGrowthData {
                // Datos de peso
                if !pesoRegistros.isEmpty {
                    drawText("Registros de Peso", in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 20),
                             font: .boldSystemFont(ofSize: 16), color: .black)
                    yPosition += 30
                    
                    for registro in pesoRegistros {
                        drawText("\(registro.fecha): \(registro.peso) kg",
                                 in: CGRect(x: 60, y: yPosition, width: pageWidth - 120, height: 20),
                                 font: .systemFont(ofSize: 12), color: .black)
                        yPosition += 25
                        
                        if yPosition > pageHeight - 50 {
                            context.beginPage()
                            yPosition = 50
                        }
                    }
                    yPosition += 20
                }
                
                // Datos de estatura
                if !estaturaRegistros.isEmpty {
                    drawText("Registros de Estatura", in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 20),
                             font: .boldSystemFont(ofSize: 16), color: .black)
                    yPosition += 30
                    
                    for registro in estaturaRegistros {
                        drawText("\(registro.fecha): \(registro.estatura) cm",
                                 in: CGRect(x: 60, y: yPosition, width: pageWidth - 120, height: 20),
                                 font: .systemFont(ofSize: 12), color: .black)
                        yPosition += 25
                        
                        if yPosition > pageHeight - 50 {
                            context.beginPage()
                            yPosition = 50
                        }
                    }
                    yPosition += 20
                }
                
                // Datos de IMC
                if !imcRegistros.isEmpty {
                    drawText("Registros de IMC", in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 20),
                             font: .boldSystemFont(ofSize: 16), color: .black)
                    yPosition += 30
                    
                    for registro in imcRegistros {
                        drawText("\(registro.fecha): \(registro.imc)",
                                 in: CGRect(x: 60, y: yPosition, width: pageWidth - 120, height: 20),
                                 font: .systemFont(ofSize: 12), color: .black)
                        yPosition += 25
                        
                        if yPosition > pageHeight - 50 {
                            context.beginPage()
                            yPosition = 50
                        }
                    }
                }
            }
            
            // Sección de historial de chats (ejemplo)
            if exportChatHistory {
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 50
                }
                
                drawText("Historial de Chats", in: CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 20),
                         font: .boldSystemFont(ofSize: 16), color: .black)
                yPosition += 30
                
                // Aquí iría el código para mostrar los chats reales
                drawText("(Los datos de chat se mostrarían aquí)",
                         in: CGRect(x: 60, y: yPosition, width: pageWidth - 120, height: 20),
                         font: .systemFont(ofSize: 12), color: .black)
            }
        }
    }
    
    private func generateCSVData() throws -> Data {
        var csvString = "Tipo,Dato,Fecha\n"
        
        let babyInfo = babyData[selectedBaby] ?? (name: selectedBaby, birthDate: "", gender: "", parentName: "", parentEmail: "")
        
        // Agregar información del bebé
        csvString += "Información,Nombre,\(babyInfo.name)\n"
        csvString += "Información,Fecha de nacimiento,\(babyInfo.birthDate)\n"
        csvString += "Información,Género,\(babyInfo.gender)\n"
        csvString += "Información,Padre/Madre,\(babyInfo.parentName)\n"
        
        if exportGrowthData {
            // Agregar datos de peso
            for registro in pesoRegistros {
                csvString += "Peso,\(registro.peso) kg,\(registro.fecha)\n"
            }
            
            // Agregar datos de estatura
            for registro in estaturaRegistros {
                csvString += "Estatura,\(registro.estatura) cm,\(registro.fecha)\n"
            }
            
            // Agregar datos de IMC
            for registro in imcRegistros {
                csvString += "IMC,\(registro.imc),\(registro.fecha)\n"
            }
        }
        
        if exportChatHistory {
            // Ejemplo de datos de chat
            csvString += "Chat,Consulta sobre alimentación,05/04/2024\n"
            csvString += "Chat,¿Qué vacunas necesita a los 6 meses?,10/04/2024\n"
        }
        
        guard let data = csvString.data(using: .utf8) else {
            throw ExportError.encodingError
        }
        
        return data
    }
    
    private func generateJSONData() throws -> Data {
        let babyInfo = babyData[selectedBaby] ?? (name: selectedBaby, birthDate: "", gender: "", parentName: "", parentEmail: "")
        
        var jsonData: [String: Any] = [
            "babyInfo": [
                "name": babyInfo.name,
                "birthDate": babyInfo.birthDate,
                "gender": babyInfo.gender,
                "parentName": babyInfo.parentName,
                "parentEmail": babyInfo.parentEmail
            ],
            "exportDate": Date().ISO8601Format()
        ]
        
        if exportGrowthData {
            var growthData: [String: [[String: String]]] = [
                "peso": [],
                "estatura": [],
                "imc": []
            ]
            
            // Datos de peso
            growthData["peso"] = pesoRegistros.map {
                ["valor": $0.peso, "unidad": "kg", "fecha": $0.fecha]
            }
            
            // Datos de estatura
            growthData["estatura"] = estaturaRegistros.map {
                ["valor": $0.estatura, "unidad": "cm", "fecha": $0.fecha]
            }
            
            // Datos de IMC
            growthData["imc"] = imcRegistros.map {
                ["valor": $0.imc, "fecha": $0.fecha]
            }
            
            jsonData["growthData"] = growthData
        }
        
        if exportChatHistory {
            // Ejemplo de datos de chat
            jsonData["chatHistory"] = [
                ["date": "05/04/2024", "content": "Consulta sobre alimentación"],
                ["date": "10/04/2024", "content": "¿Qué vacunas necesita a los 6 meses?"]
            ]
        }
        
        return try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
    }
    
    private func saveTempFile(data: Data, extension: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Datos_\(selectedBaby)_\(Date().formatted(.dateTime.day().month().year().hour().minute())).\(`extension`)"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    private func cleanupTempFile() {
        if let url = tempPDFURL {
            try? FileManager.default.removeItem(at: url)
            tempPDFURL = nil
        }
    }
    
    private func drawText(_ text: String, in rect: CGRect, font: UIFont, color: UIColor) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        text.draw(in: rect, withAttributes: attributes)
    }
}

// MARK: - Vistas de Previsualización

struct PDFPreviewView: View {
    let pdfData: Data
    
    var body: some View {
        PDFKitView(data: pdfData)
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(data: data)
    }
}

struct TextPreviewView: View {
    let text: String
    
    var body: some View {
        ScrollView {
            Text(text)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Controlador de Actividad

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            self.presentationMode.wrappedValue.dismiss()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Errores Personalizados

enum ExportError: Error, LocalizedError {
    case unsupportedFormat
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "Formato de exportación no soportado"
        case .encodingError:
            return "Error al codificar los datos"
        }
    }
}

// MARK: - Vista Previa

struct ExportDataView_Previews: PreviewProvider {
    static var previews: some View {
        ExportDataView()
    }
}
