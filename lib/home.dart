import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'main.dart';
import 'package:camera/camera.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output= '';

  loadCamera(){
    cameraController=CameraController(camera![0], ResolutionPreset.medium );
    cameraController!.initialize().then((value) {
      if(!mounted){
        return;
      }
      else{
        setState(() {
          cameraController!.startImageStream((imageStream) {
            cameraImage=imageStream;
            runModel();
          });
        });
      }
    });
  }



  Interpreter? interpreter; // Declare a variable to hold the TFLite model interpreter.

// Initialize the model interpreter.
  Future<void> loadModel() async {
    var interpreter = await tfl.Interpreter.fromAsset('assets/your_model.tflite');
    final modelFile = await tfl.loadModel(
      model: 'assets/your_model.tflite', // Replace with the path to your model.
    );

    interpreter = Interpreter.fromBuffer(modelFile!);
  }

// Run inference on the camera frame.
  Future<void> runModel() async {
    if (cameraImage != null && interpreter != null) {
      final inputShape = interpreter!.getInputTensor(0).shape;
      final inputType = interpreter!.getInputTensor(0).type;

      // Preprocess the camera frame and prepare the input tensor.
      // You will need to adapt this part based on your model's requirements.

      final inputData = <int, dynamic>{
        0: cameraImage!.planes[0].bytes,
      };

      final outputData = <int, dynamic>{
        0: List.filled(inputShape[1], List.filled(inputShape[2], List.filled(inputShape[3], 0.0))),
      };

      // Run inference.
      interpreter!.runForMultipleInputs(inputData as List<Object>, outputData);

      // Process the output as needed.
      final outputTensor = interpreter!.getOutputTensor(0);
      final outputDataBuffer = outputData[outputTensor.index];

      // Update the UI or perform further processing with the outputDataBuffer.
      setState(() {
        output = 'Inference result: ${outputDataBuffer.toString()}';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emotion Detection"),
      ),
    );
  }


}
