//
//  Info+IdentitySection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import PreviewAssets
import ProseCoreStub
import ProseUI
import SharedModels
import SwiftUI

struct IdentitySection: View {
    let model: IdentitySectionModel

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            avatar()
                .frame(width: 100.0, height: 100.0)
                .cornerRadius(10.0)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            VStack(spacing: 4) {
                ContentCommonNameStatusComponent(
                    name: model.fullName,
                    status: model.status
                )

                Text("\(model.jobTitle) at \(model.company)")
                    .font(.system(size: 11.5))
                    .foregroundColor(.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func avatar() -> some View {
        if let imageName = model.avatar {
            Image(imageName)
                .resizable()
        } else {
            Image(systemName: "person.fill")
        }
    }
}

public struct IdentitySectionModel: Equatable {
    let avatar: String?
    let fullName: String
    let status: OnlineStatus
    let jobTitle: String
    let company: String

    public init(
        avatar: String?,
        fullName: String,
        status: OnlineStatus,
        jobTitle: String,
        company: String
    ) {
        self.avatar = avatar
        self.fullName = fullName
        self.status = status
        self.jobTitle = jobTitle
        self.company = company
    }
}

public extension IdentitySectionModel {
    init(
        from user: User,
        status: OnlineStatus
    ) {
        self.init(
            avatar: user.avatar,
            fullName: user.fullName,
            status: status,
            jobTitle: user.jobTitle,
            company: user.company
        )
    }
}

extension IdentitySectionModel {
    /// Only for previews
    static var valerian: Self {
        Self(
            avatar: PreviewImages.Avatars.valerian.rawValue,
            fullName: "Valerian Saliou",
            status: .online,
            jobTitle: "CTO",
            company: "Crisp"
        )
    }
}

struct IdentitySection_Previews: PreviewProvider {
    static var previews: some View {
        IdentitySection(model: .valerian)
    }
}
