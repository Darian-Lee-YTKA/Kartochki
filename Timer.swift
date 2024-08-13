//
//  Timer.swift
//  Kartochki
//
//  Created by Darian Lee on 7/23/24.
//

import Foundation
import Combine


class TimerManager: ObservableObject {
    private var timer: Timer?
    @Published var counter: Int = 0
    var goalTime: Int
    
    init(goalTime: Int = 45) {
        print("opening timer")
        self.goalTime = goalTime
        resetTimer()
    }
    
    func startTimer() {
        print("start")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.counter > 0 {
                self.counter -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        print("stopping timer")
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        print("resetting timer")
        stopTimer()
        self.counter = goalTime
        startTimer()
    }
}



