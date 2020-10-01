//
//  ContentView.swift
//  car_brand_classifier
//
//  Created by 范宇铭 on 2020/9/12.
//  Copyright © 2020 范宇铭. All rights reserved.
//

import UIKit
import SwiftUI
import CoreML

let model = car_brand_classifier_1()

struct ContentView: View {
    
    @State var showPersonInfo = false
    
    @State private var isShowPhotoLibrary = false
    @State private var image = UIImage()
    
    @State private var showCarBrand = false
    @State private var carBrand: String = ""
    
    var body: some View {
        VStack {
            NavigationView {
                // Navigation Content
                VStack {
                    
                    if showCarBrand {
                        Text(carBrand)
                            .font(.largeTitle)
                    }
                    
                    Text("Car Type Identifier")
                        .font(.headline)
                    // image presenter
                    Image(uiImage: self.image)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 200)
                        .background(Color.gray)
                        .edgesIgnoringSafeArea(.all)
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            guard let classifierOutput = try? model.prediction(image: buffer(from: self.image)!) else {
                                fatalError("Unexpected runtime error.")
                            }
                            
                            let mostOutput = classifierOutput.classLabel
                            self.showCarBrand = true
                            self.carBrand = mostOutput
                            print("brand: " + mostOutput)
                        }
                    }) {
                        HStack {
                            Text("Identify")
                                .font(.headline)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Select Pic button
                    Button(action: {
                        print("Select Pic button pressed...")
                        self.isShowPhotoLibrary = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                            Text("Select A Photo")
                                .font(.headline)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                    .sheet(isPresented: $isShowPhotoLibrary) {
                        ImagePicker(selectedImage: self.$image, sourceType: .photoLibrary)
                    }
                    // Navigation Bar
                    .navigationBarTitle("CheckYourCar", displayMode: .large)
                    .navigationBarItems(trailing:
                        HStack {
                            Button(action: {
                                print("Person Symbol button pressed...")
                                self.showPersonInfo.toggle()
                            }) {
                                Image(systemName: "person")
                                    .font(Font.system(.title))
                            }
                        }
                    )
            }.sheet(isPresented: $showPersonInfo) {
                PersonInfo()
            }
            
            VStack {
                Text("SIT223_GROUP22")
            }
        }
        
    }
}

struct PersonInfo: View {
    var body: some View {
        NavigationView {
            Text("account info")
            .navigationBarTitle(Text("My Account"), displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


func buffer(from image: UIImage) -> CVPixelBuffer? {
    
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer : CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard (status == kCVReturnSuccess) else {
    return nil
    }

    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

    context?.translateBy(x: 0, y: image.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)

    UIGraphicsPushContext(context!)
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

    return pixelBuffer
}
