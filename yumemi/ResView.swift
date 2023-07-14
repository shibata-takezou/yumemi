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
                Text("\(responseData.name) ・ \(responseData.capital)")
                    .font(.title)
                if let citizenDay = responseData.citizen_day {
                    Text("県民の日: \(citizenDay.month)/\(citizenDay.day)")
                        .font(.headline)
                        .padding()
                }
                VStack{
                    Text("\(responseData.brief)")
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.red, lineWidth: 3)
                )
                .padding()
                if responseData.has_coast_line{
                    Text("\(responseData.name)は海岸に接しています。")
                }
                else{
                    Text("\(responseData.name)は海岸に接していません。")
                }
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
            .scaledToFill()
            .opacity(0.5)
        )
    }
}

struct ResView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
