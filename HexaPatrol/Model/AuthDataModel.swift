//
//  AuthDataModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

// MARK: - LoginResponse
struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: LoginData
}

// MARK: - LoginData
struct LoginData: Codable {
    let token: String
    let tokenType: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case token
        case tokenType = "token_type"
        case user
    }
}

// MARK: - User
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let department: String
    let role: String
    let isActive: Bool
    let sequentialChecklist: Bool
    let conditionalSync: Bool
    let multiplePatrol: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, email, department, role
        case isActive = "is_active"
        case sequentialChecklist = "sequential_checklist"
        case conditionalSync = "conditional_sync"
        case multiplePatrol = "multiple_patrol"
    }
}

// MARK: - HierarchyResponse
struct HierarchyResponse: Codable {
    let data: [PlantData]
}

// MARK: - PlantData
struct PlantData: Codable, Identifiable {
    let plantID: Int
    let plantName: String
    let areaData: [AreaData]

    var id: Int { plantID }

    enum CodingKeys: String, CodingKey {
        case plantID = "plant_id"
        case plantName = "plant_name"
        case areaData = "area_data"
    }
}

// MARK: - AreaData
struct AreaData: Codable, Identifiable {
    let areaID: Int
    let areaName: String
    let equipmentGroup: [EquipmentGroup]

    var id: Int { areaID }

    enum CodingKeys: String, CodingKey {
        case areaID = "area_id"
        case areaName = "area_name"
        case equipmentGroup = "equipment_group"
    }
}

// MARK: - EquipmentGroup
struct EquipmentGroup: Codable, Identifiable {
    let equipmentGroupID: Int
    let equipmentGroupName: String
    let equipmentType: [EquipmentType]

    var id: Int { equipmentGroupID }

    enum CodingKeys: String, CodingKey {
        case equipmentGroupID = "equipment_group_id"
        case equipmentGroupName = "equipment_group_name"
        case equipmentType = "equipment_type"
    }
}

// MARK: - EquipmentType
struct EquipmentType: Codable, Identifiable {
    let equipmentTypeID: Int
    let equipmentTypeName: String
    let tagno: [Tagno]

    var id: Int { equipmentTypeID }

    enum CodingKeys: String, CodingKey {
        case equipmentTypeID = "equipment_type_id"
        case equipmentTypeName = "equipment_type_name"
        case tagno
    }
}

// MARK: - Tagno
struct Tagno: Codable, Identifiable {
    let tagnoID: Int
    let tagnoName: String
    let parameter: [Parameter]

    var id: Int { tagnoID }

    enum CodingKeys: String, CodingKey {
        case tagnoID = "tagno_id"
        case tagnoName = "tagno_name"
        case parameter
    }
}

// MARK: - Parameter
struct Parameter: Codable, Identifiable {
    let parameterID: Int
    let parameterName: String
    let unit: String
    let formType: String
    let booleanOption: String
    let correctOption: String
    let gap: String
    let mandatory: Mandatory
    let min: Int?
    let max: Int?
    let ordering: Int

    var id: Int { parameterID }

    enum CodingKeys: String, CodingKey {
        case parameterID = "parameter_id"
        case parameterName = "parameter_name"
        case unit
        case formType = "form_type"
        case booleanOption = "boolean_option"
        case correctOption = "correct_option"
        case gap = "gap"
        case mandatory, min, max, ordering
    }
}

enum Mandatory: Codable {
    case int(Int)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else {
            throw DecodingError.typeMismatch(Mandatory.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value is neither Int nor Bool"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        }
    }
}

enum StringOrNumber: Codable {
    case string(String)
    case number(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let numberValue = try? container.decode(Double.self) {
            self = .number(numberValue)
        } else {
            throw DecodingError.typeMismatch(StringOrNumber.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value is neither String nor Number"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        }
    }
}

struct ErrorResponse: Codable {
    let message: String
}


