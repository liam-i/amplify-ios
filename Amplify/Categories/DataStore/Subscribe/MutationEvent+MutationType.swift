//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension MutationEvent {
    enum MutationType: String, Codable {
        case create
        case update
        case delete
    }
}

public extension MutationEvent.MutationType {
    var graphQLMutationType: GraphQLMutationType {
        switch self {
        case .create:
            return .create
        case .update:
            return .update
        case .delete:
            return .delete
        }
    }
}