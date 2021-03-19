//
//  ContentView.swift
//  MyOkashi
//
//  Created by daito yamashita on 2021/03/17.
//

import SwiftUI

struct ContentView: View {
    // OkashiDataを参照する状態変数
    @ObservedObject var okashiDataList = OkashiData()
    
    // 入力された文字列を保持する状態変数
    @State var inputText = ""
    
    // SafariViewの表示有無を管理する変数
    @State var showSafari = false
    
    var body: some View {
        VStack {
            TextField("キーワードを入力してください", text: $inputText, onCommit: {
                //入力完了直後に検索をする
                okashiDataList.searchOkashi(keyword: inputText)
            })
            
            .padding()
            
            // リストを表示する
            List(okashiDataList.okashiList) { okashi in
                
                Button(action: {
                    // SafariViewを表示する、toggle()でtrue、falseの切り替え
                    showSafari.toggle()
                }) {
                    // okashiに要素を取り出して、List（一覧）を生成する
                    HStack {
                        Image(uiImage: okashi.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 40)
                        Text(okashi.name)
                    }
                }
                
                .sheet(isPresented: self.$showSafari, content: {
                    // SafariViewを表示する
                    SafariView(url: okashi.link)
                        
                        // 画面下部いっぱいにしてセーフエリア外まで持ってくる
                        .edgesIgnoringSafeArea(.bottom)
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
