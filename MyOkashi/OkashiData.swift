//
//  OkashiData.swift
//  MyOkashi
//
//  Created by daito yamashita on 2021/03/17.
//

import Foundation
import UIKit

// Identifiableプロトコルを利用して、お菓子の情報をまとめる構造体
struct OkashiItem: Identifiable {
    let id = UUID()
    let name: String
    let link: URL
    let image: UIImage
}

// お菓子データ検索用クラス
class OkashiData: ObservableObject {
    
    // Jsonのデータ構造
    struct ResultJson: Codable {
        // Jsonのitem内のデータ構造
        struct Item: Codable {
            // お菓子の名称
            let name: String?
            // 掲載URL
            let url: URL?
            // 画像URL
            let image: URL?
        }
        // 複数要素
        let item: [Item]?
    }
    
    // お菓子のリスト（Identifiableプロトコル）
    @Published var okashiList: [OkashiItem] = []
    
    // Web API 検索用メソッド　第一引数：keyword 検索したいキーワード
    func searchOkashi(keyword: String) {
        // デバッグエリアに出力
        print(keyword)
        
        // お菓子の検索キーワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        // リクエストURLの組み立て
        guard let req_url = URL(string: "https://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        print(req_url)
        
        // リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        
        // データ転送を管理するためのセッションを生成
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        // リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: { (data, response, error) in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                
                let json = try decoder.decode(ResultJson.self, from: data!)
                
//                print(json)
                
                // お菓子の情報が取得できているか確認
                if let items = json.item {
                    
                    // お菓子リストを初期化
                    self.okashiList.removeAll()
                    
                    // 取得しているお菓子の数だけ処理
                    for item in items {
                        
                        // お菓子の名称、掲載URL、画像URLをアンラップ
                        if let name = item.name,
                           let link = item.url,
                           let imageURL = item.image,
                           let imageData = try? Data(contentsOf: imageURL) ,
                           let image = UIImage(data: imageData)?.withRenderingMode(.alwaysOriginal) {
                            
                            // ひとつのお菓子を構造体でまとめて管理
                            let okashi = OkashiItem(name: name, link: link, image: image)
                            
                            // お菓子の配列へ追加
                            self.okashiList.append(okashi)
                        }
                    }
                    print(self.okashiList)
                }
            } catch {
                print("エラーが出ました")
            }
        })
        task.resume()
    }
}
