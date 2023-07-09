//
//  ContentView.swift
//  yumemi
//
//  Created by 柴田武蔵 on 2023/07/03.
//

import SwiftUI
struct User: Codable{
    var name:String
    var birthday:YearMonthDay
    var blood_type:String
    var today:YearMonthDay
}
struct YearMonthDay:Codable{
    var year: Int
    var month: Int
    var day: Int
}
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
    guard let url = URL(string: "https://yumemi-ios-junior-engineer-codecheck.app.swift.cloud/my_fortune?API-Version=v1") else {
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

struct ContentView: View {
    @State private var responseData: Response?

    var body: some View {
        VStack {
            if let responseData = responseData {
                Text("Name: \(responseData.name)")
                Text("Brief: \(responseData.brief)")
                Text("Capital: \(responseData.capital)")
                if let citizenDay = responseData.citizen_day {
                    Text("Citizen Day: \(citizenDay.month)/\(citizenDay.day)")
                }
                Text("Has Coast Line: \(String(responseData.has_coast_line))")
                Text("Logo URL: \(responseData.logo_url)")
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            let user = User(
                name: "柴田武蔵",
                birthday: YearMonthDay(year: 2003, month: 3, day: 17),
                blood_type: "a",
                today: YearMonthDay(year: 2023, month: 7, day: 10)
            )
            print(user)
            postUser(user: user) { response in
                self.responseData = response
            }
        }
        .padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
