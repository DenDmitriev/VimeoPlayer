//
//  ContentView.swift
//  VimeoPlayer
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VimeoPlayer(viewModel: VimeoPlayerViewModel())
    }
}

#Preview {
    ContentView()
}
