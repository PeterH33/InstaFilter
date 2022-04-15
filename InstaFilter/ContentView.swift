//
//  ContentView.swift
//  InstaFilter
//
//  Created by Peter Hartnett on 2/28/22.
//
//Day 67 challenges
// 1 Try making the Save button disabled if there is no image in the image view
// 2 Experiment with having more than one slider for controlling the variables
// 3 Add 3 more Core Image filters, the changes made in challenge 2 need to work with the filters that are added to the code.

//All challenges are complete and the addition of more filters becomes mostly trivial. I am not sure how to implement vectors for some of the keys to give the position of an effect, I left bump distortion in there and messed up to specifically highlight that issue.
//I could not get any kCI Keys for bokehBlur to show up, so I did not implement that one, it just behaves differently and could use some more inspection to get it working.

//Future improvements
//get all the filters in and working (specificially the values to use in applyProcessing() to make the sliders work in a rasonable manner and clean up the selection box for the filters.
//Application of multiple filters would be good too, the order filters are applied in matters.
//Might be fun to have a "Random filter" option that just hits a random number of filters and shows the result

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    
    
    //Challenge 1 state
    @State private var imageLoaded = false
    
    @State private var showingFilterSheet = false
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    
    //Challenge 2 States to track which sliders should be active
    @State private var showInputIntensitySlider = false
    @State private var filterIntensity = 1.0
    @State private var showInputRadiusSlider = false
    @State private var filterRadius = 0.5
    @State private var showInputScaleSlider = false
    @State private var filterScale = 0.5
    @State private var showInputAngleSlider = false
    @State private var filterAngle = 0.5
    
    
    func loadImage() {
        guard let inputImage = inputImage else { return }

        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
        //Challenge 1 flag toggle should occur once, need to see if there is some way to remove the image from the view that might prevent this logic from working
        imageLoaded = true
    }
    
    func save() {
        guard let processedImage = processedImage else { return }

        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            print("Success!")
        }

        imageSaver.errorHandler = {
            print("Oops: \($0.localizedDescription)")
        }
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        //Chalenge 2 this would be a good place to add the logic of what sliders to render
        let inputKeys = currentFilter.inputKeys
       
        showInputIntensitySlider = inputKeys.contains(kCIInputIntensityKey) ? true : false
        showInputRadiusSlider = inputKeys.contains(kCIInputRadiusKey) ? true : false
        showInputScaleSlider = inputKeys.contains(kCIInputScaleKey) ? true : false
        showInputAngleSlider = inputKeys.contains(kCIInputAngleKey) ? true : false
        
        loadImage()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        //Challenge 2 Make sure that the new logic for the sliders does not interfere with non existant keys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputAngleKey) {
            currentFilter.setValue(filterAngle * 3.6, forKey: kCIInputAngleKey)
        }

        guard let outputImage = currentFilter.outputImage else { return }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)

                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)

                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                    // select an image
                }
                //Challenge 2 add in logic for the sliders to be present only when they are availible to the current filter. We could have the sliders appear and disapear, or we could simply flag them as disabled when not in use.
                sliderView
                    .padding(.vertical)


                HStack {
                    Button("Change Filter") {
                        showingFilterSheet = true
                    }

                    Spacer()

                    Button("Save", action: save)
                    //Last bit of challenge one logic if image is not loaded, disable button.
                        .disabled(!imageLoaded)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                filterConfirmationDialogView
            }
            .onChange(of: inputImage) { _ in loadImage() }
        }
    }
    
    private var filterConfirmationDialogView: some View{
        //The Vstack is pointless, it can be just about anything for the ConfirmaitonDialog and it looks the same
        VStack{
            //Challenge 3 add more filters here
            //The filter buttons are in a group so that I can get more than 10 in a row, the confirmation dialog ignores them, but you still need to keep things under 10
            Group{
            Button("Crystallize") { setFilter(CIFilter.crystallize()) }
            Button("Edges") { setFilter(CIFilter.edges()) }
            Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
            Button("Pixellate") { setFilter(CIFilter.pixellate()) }
            Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
            Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
            Button("Vignette") { setFilter(CIFilter.vignette()) }
            Button("Bloom") { setFilter(CIFilter.bloom())}
            Button("Motion Blur") {setFilter(CIFilter.motionBlur())}
            Button("Bump Distortion") {setFilter(CIFilter.bumpDistortion())}
            
            
            
        }
        Group{
            Button("Cancel", role: .cancel) { }
        }
        }
    }
    
    //I feel like this slider view could be cleaned up and made less repeditive.
    private var sliderView: some View{
        VStack{
            if showInputIntensitySlider{
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in
                            applyProcessing()
                        }
                }
            }
            if showInputRadiusSlider{
                HStack {
                    Text("Radius")
                    Slider(value: $filterRadius)
                        .onChange(of: filterRadius) { _ in
                            applyProcessing()
                        }
                }
            }
            if showInputScaleSlider{
                HStack {
                    Text("Scale")
                    Slider(value: $filterScale)
                        .onChange(of: filterScale) { _ in
                            applyProcessing()
                        }
                }
            }
            if showInputAngleSlider{
                HStack {
                    Text("Angle")
                    Slider(value: $filterAngle)
                        .onChange(of: filterAngle) { _ in
                            applyProcessing()
                        }
                }
                
                
            }
            
        }//endVstack
    }//End SliderView
    
    
}//End Contentview





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
