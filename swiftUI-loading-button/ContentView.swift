//
//  ContentView.swift
//  swiftUI-loading-button
//
//  Created by Joanna Lingenfelter on 7/4/22.
//

import SwiftUI
import Combine

protocol LoadingButtonStyle: ButtonStyle {
    init(isLoading: Bool)
}


struct LoadingButton<ButtonStyle: LoadingButtonStyle, Content: View>: View {
    let buttonStyle: ButtonStyle.Type
    let action: () -> Void
    let label: () -> Content

    @Binding private var isLoading: Bool

    init(buttonStyle: ButtonStyle.Type, isLoading: Binding<Bool>, action: @escaping () -> Void, label: @escaping () -> Content) {
        self.buttonStyle = buttonStyle
        _isLoading = isLoading
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: action, label: label)
            .buttonStyle(buttonStyle.init(isLoading: isLoading))
    }
}

struct MyButtonStyle: LoadingButtonStyle {
    let isLoading: Bool

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        return configuration.label
        .padding(.vertical)
        .padding(.horizontal, 20)
        .foregroundColor(.white)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .opacity(isLoading ? 0.5 : 1.0)
        .overlay(
            Color.black
                .opacity(configuration.isPressed ? 0.2 : 0.0)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        )
        .overlay {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}

struct Loader: ViewModifier {
    @Binding var isLoading: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0.5: 1.0)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }

    }
}

extension View {
    func loading(_ bool: Binding<Bool>) -> some View {
        modifier(Loader(isLoading: bool))
    }
}

struct ContentView: View {
    @State var button1IsLoading: Bool = false
    @State var button2IsLoading: Bool = false

    var body: some View {
        VStack {
            LoadingButton(buttonStyle: MyButtonStyle.self, isLoading: $button1IsLoading) {
                withAnimation(.easeInOut) {
                    button1IsLoading.toggle()
                }
                print("Pressed!")
            } label: {
                Text("Press me!")
            }

            Button("Press me!") {
                withAnimation(.easeInOut) {
                    button2IsLoading.toggle()
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
            .foregroundColor(.white)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .loading($button2IsLoading)
        }

        Button("Press me!") {

        }
        .padding(.vertical)
        .padding(.horizontal, 20)
        .foregroundColor(.white)
        .background(Color.red)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
