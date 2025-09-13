/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Utility views and functions.
*/


//  Copyright © 2023-2024 Alejandro Garcia <iacobus75@gmail.com>  <alejandro@kayros.uno>
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import SwiftUI

//Los tipos de VistaActiva
enum TipoVistaActiva
{
    case cluster    //Vista cluster
    case root       //Vista root
    case latency    //Vista latencia
    case bandwith   //Vista BW
    case mtu        //Vista MTU
    
}

enum TimeRange {
    case last30Days
    case last12Months
}

struct TimeRangePicker: View {
    @Binding var value: TimeRange

    var body: some View {
        Picker(selection: $value.animation(.easeInOut), label: EmptyView()) {
            Text("30 Days").tag(TimeRange.last30Days)
            Text("12 Months").tag(TimeRange.last12Months)
        }
        .pickerStyle(.segmented)
    }
}

struct Transaction: Identifiable, Hashable {
    let id = UUID()
}

/// A few fake transactions for display.
let transactions = [
    Transaction(),
    Transaction(),
    Transaction(),
    Transaction(),
    Transaction(),
    Transaction(),
    Transaction(),
    Transaction()
]

struct TransactionsLink: View {
    var body: some View {
        NavigationLink("Show Transactions", value: transactions)
    }
}

struct TransactionsView: View {
    let transactions: [Transaction]

    var body: some View {
        List {
            ForEach(transactions) { _ in
                HStack { Text("Year Month Day"); Text("Style"); Spacer(); Text("123") }
            }
        }
        .redacted(reason: .placeholder)
        .navigationTitle("Transactions")
    }
}
