//
//  PlayView.swift
//  palmcards
//
//  Created by Вадим Мартыненко on 21.03.2023.
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject var dictionaryViewModel: DictionaryViewModel
    @EnvironmentObject var settings: Settings
    @State private var doCardsNavigate: Bool = false
    @State private var doWritingNavigate: Bool = false
    @State var chosenDictionaries: [String] = []
    
    @State var test: Bool = false

    let listOfTypeGames = ["cards", "write words"]
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color("background")
                    .ignoresSafeArea()
                
                VStack{
                    if dictionaryViewModel.dictionaries.isEmpty {
                        NoItemDictionaryView()
                    } else {
                        VStack{
                            List {
                                ForEach(dictionaryViewModel.dictionaries) { dictionary in
                                    ItemListSelectDictionaries(
                                        chosenDictionaries: $chosenDictionaries,
                                        nameDictionary: dictionary.name,
                                        idDictionary: dictionary.id
                                    )
                                }
                            }
                            .frame(height: 400)
                            
                            if getListWordsFromChosenDictionaries().isEmpty {
                                Spacer()
                                NoItemWordsWithoutScrollView()
                            }
                        }
                    }
                    Spacer()
                    
                    Button(action: {
                        if settings.selectTypeOfGame == .writing {
                            doWritingNavigate.toggle()
                        } else {
                            doCardsNavigate.toggle()
                        }
                    }) {
                        Text("Играть")
                            .tint(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(dictionaryViewModel.dictionaries.isEmpty || getListWordsFromChosenDictionaries().isEmpty ? Color.gray.opacity(0.2) : Color.blue)
                            .cornerRadius(15)
                            .padding()
                    }
                    .disabled(dictionaryViewModel.dictionaries.isEmpty || getListWordsFromChosenDictionaries().isEmpty ? true : false)
                    
                    NavigationLink(value: "CardsPlayingView", label: {
                        EmptyView()
                    })
                    .navigationDestination(isPresented: $doCardsNavigate) {
                        CardsPlayingView(chosenDictionaries: chosenDictionaries, listWords: getListWordsFromChosenDictionaries())
                    }
                    
                    NavigationLink(value: "WritingPlayingView", label: {
                        EmptyView()
                    })
                    .navigationDestination(isPresented: $doWritingNavigate) {
                        WritingPlayingView(chosenDictionaries: chosenDictionaries, listWords: getListWordsFromChosenDictionaries())
                    }
                }
            }
            .navigationTitle("Играть")
            .onAppear{
                if !dictionaryViewModel.dictionaries.isEmpty {
                    if let data = UserDefaults.standard.data(forKey: "chosenDictionaries") {
                        let savedItems = try? JSONDecoder().decode([String].self, from: data)
                            if let takeSavedItems = savedItems {
                                var listDeletedDictionaries: [String] = []
                                
                                // в listDeletedDictionaries добавляем id тех словарей, которые содержится в сохраненной в память переменной chosenDictionaries, но не содержится в списке словарей
                                
                                takeSavedItems.forEach { item in
                                    if !dictionaryViewModel.dictionaries.contains(where: {$0.id == item}) {
                                        listDeletedDictionaries.append(item)
                                    }
                                }
                                
                                // если переменная пустая, то делаем просто инициализацию, в ином случае из takeSavedItems извлекаем словари, которых не существует и сохраняем измененую переменную

                                if listDeletedDictionaries.isEmpty {
                                    chosenDictionaries = takeSavedItems
                                } else {
                                    chosenDictionaries = takeSavedItems.filter({ item in
                                        return !listDeletedDictionaries.contains(item)
                                    })
                                    
                                    if let encodingData = try? JSONEncoder().encode(chosenDictionaries) {
                                        UserDefaults.standard.set(encodingData, forKey: "chosenDictionaries")
                                    }
                                }
                        }
                    }
                } else {
                    chosenDictionaries = []
                    if let encodingData = try? JSONEncoder().encode(chosenDictionaries) {
                        UserDefaults.standard.set(encodingData, forKey: "chosenDictionaries")
                    }
                }
            }
        }
    }
    
    func getListWordsFromChosenDictionaries() -> [WordsModel] {
        var listWords: [WordsModel] = []
        
        if !chosenDictionaries.isEmpty {
            for chosenDictionaryID in chosenDictionaries {
                listWords += dictionaryViewModel.getListWord(id: chosenDictionaryID)
            }
        }
        
        return listWords
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
            .environmentObject(DictionaryViewModel())
            .environmentObject(Settings())
    }
}
