//
//  ContentView.swift
//  swiftUI-loading-button
//
//  Created by Joanna Lingenfelter on 7/4/22.
//

import SwiftUI
import Combine

protocol LoadingButtonStyle: ButtonStyle {
    init(isLoading: Bool, color: Color)
}

struct LoadingButton<Style: LoadingButtonStyle, Content: View>: View {
    let buttonStyle: Style.Type
    let action: () -> Void
    let label: () -> Content
    let color: Color

    @Binding private var isLoading: Bool

    init(buttonStyle: Style.Type, isLoading: Binding<Bool>, action: @escaping () -> Void, label: @escaping () -> Content, color: Color) {
        self.buttonStyle = buttonStyle
        _isLoading = isLoading
        self.action = action
        self.label = label
        self.color = color
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                label()
                    .opacity(isLoading ? 0.0 : 1.0)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }

            }
        }
        .buttonStyle(buttonStyle.init(isLoading: isLoading, color: color))
    }
}

struct MyButtonStyle: LoadingButtonStyle {
    let isLoading: Bool
    let color: Color

    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        return configuration.label
        .padding(.vertical)
        .padding(.horizontal, 20)
        .foregroundColor(.white)
        .background(color.opacity(isLoading ? 0.4: 1.0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            Color.black
                .opacity(configuration.isPressed ? 0.2 : 0.0)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        )
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

struct LoadingButtonDynamicLabel<Style: ButtonStyle, Label: View>: View {
    let buttonStyle: Style
    let action: () -> Void
    let label: () -> Label

    @Binding var isLoading: Bool {
        didSet {
            print(isLoading)
        }
    }

    init(buttonStyle: Style, isLoading: Binding<Bool>, action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.buttonStyle = buttonStyle
        _isLoading = isLoading
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: action) {
            LoadingLabel(label: label, isLoading: $isLoading)
        }
        .buttonStyle(buttonStyle)
    }
}

struct LoadingLabel<Label>: View where Label: View {
    let label: Label

    @Binding private var isLoading: Bool {
        didSet {
            print(isLoading)
        }
    }

    init(@ViewBuilder label: () -> Label, isLoading: Binding<Bool>) {
        self.label = label()
        _isLoading = isLoading
    }

    var body: some View {
        ZStack {
            label
                .opacity(isLoading ? 0.0 : 1.0)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }

        }
    }
}

struct ContentView: View {
    @State var button1IsLoading: Bool = false
    @State var button2IsLoading: Bool = false
    @State var button3IsLoading: Bool = false

    var body: some View {
        VStack {
            // Uses first Approach
            LoadingButton(buttonStyle: MyButtonStyle.self, isLoading: $button1IsLoading, action: {
                withAnimation(.easeInOut) {
                    button1IsLoading.toggle()
                }
                print("Pressed!")
            }, label: {
                Text("Press me!")
            }, color: .blue)

            // Uses ViewModifier
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

        LoadingButtonDynamicLabel(buttonStyle: MyButtonStyle(isLoading: button3IsLoading, color: .red), isLoading: $button3IsLoading) {
            print("Button 3 pressed!")
            withAnimation {
                button3IsLoading.toggle()
            }
        } label: {
            Text("Press me!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
