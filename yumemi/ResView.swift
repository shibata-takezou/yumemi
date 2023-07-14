//
//  ResView.swift
//  yumemi
//
//  Created by 柴田武蔵 on 2023/07/10.
//

import SwiftUI
//受信JSON
struct Response:Codable{
    var name:String
    var capital:String
    var citizen_day: MonthDay?
    var has_coast_line:Bool
    var logo_url:String
    var brief:String
}
struct MonthDay:Codable{
    var month: Int
    var day: Int
}

func postUser(user: User, completion: @escaping (Response?) -> Void) {//非同期で文字を表示
    let version = "v1"
    let urlstr = "https://yumemi-ios-junior-engineer-codecheck.app.swift.cloud/my_fortune?API-Version=\(version)"
    guard let url = URL(string: urlstr) else {
        completion(nil)
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

    do {
        //JSONのエンコード
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(user)
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = data {
                do {
                    //JSONのデコード
                    let jsonDecoder = JSONDecoder()
                    let responseData = try jsonDecoder.decode(Response.self, from: data)
                    completion(responseData)
                } catch {
                    print("Error decoding response data: \(error)")
                    completion(nil)
                }
            }
        }.resume()
    } catch {
        print("Error encoding user: \(error)")
        completion(nil)
    }
}
struct ResView: View {
    @Binding var user: User
    @State private var responseData: Response?
    var body: some View{
        
        VStack {
            if let responseData = responseData {
                Text("Name: \(responseData.name)")
                Text("Brief: \(responseData.brief)")
                Text("Capital: \(responseData.capital)")
                if let citizenDay = responseData.citizen_day {
                    Text("Citizen Day: \(citizenDay.month)/\(citizenDay.day)")
                }
                Text("Has Coast Line: \(String(responseData.has_coast_line))")
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            print(user)
            postUser(user: user) { response in
                self.responseData = response
            }
        }
        .background(
            AsyncImage(url: URL(string:responseData?.logo_url ?? "0")) {
                image in image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 240, height: 126)
            .opacity(0.5)
        )
    }
}

struct ResView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
