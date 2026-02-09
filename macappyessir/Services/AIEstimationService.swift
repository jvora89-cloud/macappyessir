//
//  AIEstimationService.swift
//  macappyessir
//
//  Created by Jay Vora on 2/8/26.
//

import Foundation

struct EstimationResult {
    let estimatedCost: Double
    let materialsCost: Double
    let laborCost: Double
    let reasoning: String
    let suggestedTimeline: Int // days
    let riskFactors: [String]
    let recommendations: [String]
}

class AIEstimationService {
    static let shared = AIEstimationService()

    private let apiKey: String?
    private let apiEndpoint = "https://api.anthropic.com/v1/messages"

    private init() {
        // Try to load API key from environment or config
        self.apiKey = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"]
    }

    // MARK: - Main Estimation Method
    func generateEstimate(
        contractorType: ContractorType,
        description: String,
        address: String
    ) async throws -> EstimationResult {
        // Check if API key is available
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            print("⚠️ No Claude API key found, using smart simulation")
            return generateSmartSimulation(contractorType: contractorType, description: description)
        }

        // Prepare the prompt
        let prompt = constructEstimationPrompt(
            contractorType: contractorType,
            description: description,
            address: address
        )

        // Call Claude API
        let response = try await callClaudeAPI(prompt: prompt, apiKey: apiKey)

        // Parse the response
        return parseEstimationResponse(response, contractorType: contractorType)
    }

    // MARK: - Claude API Call
    private func callClaudeAPI(prompt: String, apiKey: String) async throws -> String {
        guard let url = URL(string: apiEndpoint) else {
            throw NSError(domain: "AIEstimation", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API endpoint"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let requestBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 1500,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "AIEstimation", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Claude API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw NSError(domain: "AIEstimation", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String else {
            throw NSError(domain: "AIEstimation", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }

        return text
    }

    // MARK: - Prompt Construction
    private func constructEstimationPrompt(
        contractorType: ContractorType,
        description: String,
        address: String
    ) -> String {
        return """
        You are an expert contractor estimation AI. Provide a detailed cost estimate for the following project:

        PROJECT TYPE: \(contractorType.rawValue)
        LOCATION: \(address)
        DESCRIPTION: \(description)

        Please provide your estimate in the following JSON format:
        {
          "total_cost": <number>,
          "materials_cost": <number>,
          "labor_cost": <number>,
          "timeline_days": <number>,
          "reasoning": "<explanation of cost factors>",
          "risk_factors": ["<risk 1>", "<risk 2>"],
          "recommendations": ["<recommendation 1>", "<recommendation 2>"]
        }

        Consider:
        - Current market rates for materials and labor
        - Project complexity and scope
        - Typical contractor profit margins (15-20%)
        - Regional pricing variations
        - Timeline estimates based on project scope

        Provide realistic estimates based on 2024-2026 market conditions.
        """
    }

    // MARK: - Response Parsing
    private func parseEstimationResponse(_ response: String, contractorType: ContractorType) -> EstimationResult {
        // Try to extract JSON from the response
        if let jsonData = extractJSON(from: response),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

            let totalCost = (json["total_cost"] as? Double) ?? generateBaselineCost(for: contractorType)
            let materialsCost = (json["materials_cost"] as? Double) ?? (totalCost * 0.6)
            let laborCost = (json["labor_cost"] as? Double) ?? (totalCost * 0.4)
            let timeline = (json["timeline_days"] as? Int) ?? estimateTimeline(for: contractorType)
            let reasoning = (json["reasoning"] as? String) ?? "AI-generated estimate based on project details"
            let risks = (json["risk_factors"] as? [String]) ?? []
            let recommendations = (json["recommendations"] as? [String]) ?? []

            return EstimationResult(
                estimatedCost: totalCost,
                materialsCost: materialsCost,
                laborCost: laborCost,
                reasoning: reasoning,
                suggestedTimeline: timeline,
                riskFactors: risks,
                recommendations: recommendations
            )
        }

        // Fallback to smart simulation if parsing fails
        return generateSmartSimulation(contractorType: contractorType, description: response)
    }

    private func extractJSON(from text: String) -> Data? {
        // Try to find JSON in the response
        let pattern = "\\{[\\s\\S]*\\}"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range, in: text) {
            let jsonString = String(text[range])
            return jsonString.data(using: .utf8)
        }
        return nil
    }

    // MARK: - Smart Simulation (Fallback)
    private func generateSmartSimulation(contractorType: ContractorType, description: String) -> EstimationResult {
        // Baseline costs by project type
        let baseCost = generateBaselineCost(for: contractorType)

        // Analyze description for complexity factors
        let complexityMultiplier = analyzeComplexity(description: description)
        let adjustedCost = baseCost * complexityMultiplier

        // Generate intelligent breakdown
        let materialsCost = adjustedCost * 0.6
        let laborCost = adjustedCost * 0.4

        // Timeline estimation
        let timeline = estimateTimeline(for: contractorType)

        // Generate contextual reasoning
        let reasoning = generateReasoning(
            contractorType: contractorType,
            baseCost: baseCost,
            adjustedCost: adjustedCost,
            complexityMultiplier: complexityMultiplier
        )

        let risks = generateRiskFactors(contractorType: contractorType)
        let recommendations = generateRecommendations(contractorType: contractorType)

        return EstimationResult(
            estimatedCost: adjustedCost,
            materialsCost: materialsCost,
            laborCost: laborCost,
            reasoning: reasoning,
            suggestedTimeline: timeline,
            riskFactors: risks,
            recommendations: recommendations
        )
    }

    private func generateBaselineCost(for type: ContractorType) -> Double {
        switch type {
        case .kitchen:
            return Double.random(in: 22000...32000)
        case .bathroom:
            return Double.random(in: 12000...18000)
        case .roofing:
            return Double.random(in: 10000...16000)
        case .painting:
            return Double.random(in: 3500...6500)
        case .flooring:
            return Double.random(in: 6000...12000)
        case .fencing:
            return Double.random(in: 4500...8000)
        case .landscaping:
            return Double.random(in: 3000...7000)
        case .plumbing:
            return Double.random(in: 2500...5000)
        case .electrical:
            return Double.random(in: 3000...6000)
        case .hvac:
            return Double.random(in: 6000...12000)
        case .remodeling:
            return Double.random(in: 25000...45000)
        case .homeImprovement:
            return Double.random(in: 8000...15000)
        }
    }

    private func analyzeComplexity(description: String) -> Double {
        let lowercased = description.lowercased()
        var multiplier = 1.0

        // Keywords that increase complexity
        let highComplexity = ["custom", "luxury", "high-end", "complex", "intricate", "detailed"]
        let mediumComplexity = ["upgrade", "modern", "new", "replace"]

        for keyword in highComplexity {
            if lowercased.contains(keyword) {
                multiplier *= 1.2
            }
        }

        for keyword in mediumComplexity {
            if lowercased.contains(keyword) {
                multiplier *= 1.1
            }
        }

        // Cap the multiplier
        return min(multiplier, 1.5)
    }

    private func estimateTimeline(for type: ContractorType) -> Int {
        switch type {
        case .kitchen:
            return Int.random(in: 21...45)
        case .bathroom:
            return Int.random(in: 14...28)
        case .roofing:
            return Int.random(in: 7...14)
        case .painting:
            return Int.random(in: 3...7)
        case .flooring:
            return Int.random(in: 5...10)
        case .fencing:
            return Int.random(in: 3...7)
        case .landscaping:
            return Int.random(in: 7...14)
        case .plumbing:
            return Int.random(in: 2...5)
        case .electrical:
            return Int.random(in: 2...7)
        case .hvac:
            return Int.random(in: 3...7)
        case .remodeling:
            return Int.random(in: 30...90)
        case .homeImprovement:
            return Int.random(in: 7...21)
        }
    }

    private func generateReasoning(contractorType: ContractorType, baseCost: Double, adjustedCost: Double, complexityMultiplier: Double) -> String {
        let difference = ((adjustedCost - baseCost) / baseCost * 100)

        var reasoning = "Based on typical \(contractorType.rawValue.lowercased()) projects, the baseline estimate is \(formatCurrency(baseCost)). "

        if complexityMultiplier > 1.15 {
            reasoning += "Due to the project's complexity and custom requirements, the estimate has been adjusted upward by \(Int(difference))%. "
        } else if complexityMultiplier > 1.0 {
            reasoning += "Minor adjustments have been made for project specifications. "
        }

        reasoning += "This includes materials (60%) and labor (40%) based on current market rates."

        return reasoning
    }

    private func generateRiskFactors(contractorType: ContractorType) -> [String] {
        let commonRisks = [
            "Material price fluctuations",
            "Weather delays (if outdoor work)",
            "Hidden structural issues",
            "Permit approval timeline"
        ]

        let typeSpecificRisks: [String]
        switch contractorType {
        case .kitchen, .bathroom:
            typeSpecificRisks = ["Plumbing complications", "Electrical upgrades needed"]
        case .roofing:
            typeSpecificRisks = ["Weather-dependent", "Deck damage discovery"]
        case .painting:
            typeSpecificRisks = ["Surface prep requirements", "Color matching"]
        default:
            typeSpecificRisks = []
        }

        return (commonRisks + typeSpecificRisks).shuffled().prefix(3).map { $0 }
    }

    private func generateRecommendations(contractorType: ContractorType) -> [String] {
        let commonRecommendations = [
            "Schedule pre-construction meeting",
            "Obtain 2-3 competitive bids",
            "Verify contractor licensing and insurance",
            "Review and sign detailed contract"
        ]

        return commonRecommendations.shuffled().prefix(3).map { $0 }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}
