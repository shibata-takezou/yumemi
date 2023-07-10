//
//  ContentView.swift
//  yumemi
//
//  Created by 柴田武蔵 on 2023/07/03.
//

import SwiftUI

//送信JSON
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

struct ContentView: View {
    @State private var user: User = User(name: "", birthday: YearMonthDay(year: 0, month: 0, day: 0), blood_type: "", today: YearMonthDay(year: 0, month: 0, day: 0))
    @State private var selectionDate = Date()
    @State private var selectedYear = 0
    @State private var selectedMonth = 0
    @State private var selectedDay = 0
    @State private var todayYear = 0
    @State private var todayMonth = 0
    @State private var todayDay = 0
    @State private var userName = ""
    @State private var blood = "a"

    var body: some View {
            NavigationStack{
                VStack (alignment: .center){
                    HStack{
                        Text("氏名")
                        Spacer()
                        TextField("氏名を入力してください", text: $userName)
                            .multilineTextAlignment(TextAlignment.trailing)
                    }
                    DatePicker("生年月日", selection: $selectionDate, displayedComponents: .date).environment(\.locale, Locale(identifier: "ja_JP"))
                    
                    HStack{
                        Text("血液型")
                        Spacer()
                        Picker(selection: $blood, label: Text("-")) {
                            Text("A").tag("a")
                            Text("B").tag("b")
                            Text("O").tag("o")
                            Text("AB").tag("ab")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                NavigationLink(destination: ResView(user: $user)) {
                    Text("送信")
                }
                .padding()
                .simultaneousGesture(TapGesture().onEnded {
                    //今日の年月日
                    let calendar = Calendar.current
                    var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                    todayYear = dateComponents.year ?? 0
                    todayMonth = dateComponents.month ?? 0
                    todayDay = dateComponents.day ?? 0
                    
                    //生年月日
                    dateComponents = calendar.dateComponents([.year, .month, .day], from: selectionDate)
                    selectedYear = dateComponents.year ?? 0
                    selectedMonth = dateComponents.month ?? 0
                    selectedDay = dateComponents.day ?? 0
                    
                    user = User(
                        name: userName,
                        birthday: YearMonthDay(year: selectedYear, month: selectedMonth, day: selectedDay),
                        blood_type: blood,
                        today: YearMonthDay(year: todayYear, month: todayMonth, day: todayDay)
                    )
                })
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
