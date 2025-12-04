//
//  RestaurantsView.swift
//  Gula
//
//  Created by María on 9/8/24.
//

import SwiftUI

struct EstablishmentView: View {
    @StateObject var viewModel: EstablishmentViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: .zero) {
                if viewModel.isListedByCity {
                    citiesView()
                } else {
                    establishmentsView(viewModel.establishments)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("establishmentSelection_restaurantsTitle")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(maxWidth: 16, maxHeight: 16)
                        .foregroundColor(.white)
                }
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.loadCitiesOrEstablishments()
        }
    }

    @ViewBuilder
    private func citiesView() -> some View {
        ForEach(viewModel.cities) { city in
            VStack(spacing: .zero) {
                if !city.establishments.isEmpty {
                    HStack {
                        Text(city.name)
                            .padding(.leading, 12)
                            .font(Font.system(size: 20))
                        Spacer()
                    }
                    .frame(height: 46)
                }
                establishmentsView(city.establishments)
            }
        }
    }

    @ViewBuilder
    private func establishmentsView(_ establishments: [Establishment]) -> some View {
        ForEach(establishments) { establishment in
            EstablishmentRow(establishment: establishment)
            .onTapGesture {
                viewModel.selectedEstablishment = establishment
                viewModel.navigateToEmptyView()
            }
        }
    }
}

struct EstablishmentRow: View {
    var establishment: Establishment

    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: establishment.image)) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
                    .overlay(
                        Color.black.opacity(0.4)
                    )
            } placeholder: {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
                    .foregroundColor(.gray)
            }

            VStack(spacing: 8) {
                Text(establishment.name)
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                Text("establishmentSelection_orderNow")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
        }
    }
}
