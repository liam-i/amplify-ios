//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PathKit

enum CommandImportModelsTasks {
    static func projectHasGeneratedModels(environment: AmplifyCommandEnvironment,
                                          args: CommandImportModels.TaskArgs) -> AmplifyCommandTaskResult {
        let modelsPath = environment.path(for: args.generatedModelsPath)
        if environment.directoryExists(atPath: modelsPath) {
            return .success("Amplify models folder found at \(modelsPath)")
        }

        return .failure(
            AmplifyCommandError(
                .folderNotFound,
                errorDescription: "We couldn't find any generated models at \(modelsPath)",
                recoverySuggestion: "Please run amplify codegen models."))
    }

    static func addGeneratedModelsToProject(environment: AmplifyCommandEnvironment,
                                            args: CommandImportModels.TaskArgs) -> AmplifyCommandTaskResult {
        let models = environment.glob(pattern: "\(args.generatedModelsPath)/*.swift").map {
            environment.createXcodeFile(withPath: $0, ofType: .source)
        }

        do {
            try environment.addFilesToXcodeProject(
                projectPath: environment.basePath,
                files: models,
                toGroup: args.modelsGroup)

            let addedModels = models.map { Path($0.path).lastComponent }
            return .success("Successfully added models \(addedModels) to '\(args.modelsGroup)' group.")
        } catch {
            return .failure(AmplifyCommandError(.xcodeProject, error: error))
        }
    }
}

public struct CommandImportModels: AmplifyCommand {
    public struct CommandImportModelsArgs {
        let modelsGroup = "AmplifyModels"
        let generatedModelsPath = "amplify/generated/models"
    }

    public typealias TaskArgs = CommandImportModelsArgs

    public static let description = "Import Amplify models"

    public var taskArgs = CommandImportModelsArgs()

    public var tasks: [AmplifyCommandTask<CommandImportModelsArgs>] = [
        .run(CommandImportModelsTasks.projectHasGeneratedModels),
        .run(CommandImportModelsTasks.addGeneratedModelsToProject)
    ]

    public init() {}

    public func onFailure() {
    }
}
