//
//  ViewController.swift
//  SwiftUIValueSlider
//
//  Created by sanhee16 on 04/12/2023.
//  Copyright (c) 2023 sanhee16. All rights reserved.
//

import UIKit
import SwiftUI
import SwiftUIValueSlider


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


struct ViewA: View {
    @State var value: Double = 0.0
    var body: some View {
        GeometryReader { gp in
            VStack {
                Spacer()
                ValueSliderView($value)
                    .onStart {
                        print(value)
                    }
                Spacer()
            }
            .navigationTitle("ViewA")
            .navigationBarBackButtonHidden()
        }
        .background(Color.yellow)
    }
}


struct ViewA_Previews: PreviewProvider {
    static var previews: some View {
        ViewA()
    }
}

