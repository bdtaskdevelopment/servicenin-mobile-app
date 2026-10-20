import Flutter
import UIKit
import SSLCommerzSDK



public class SwiftFlutterSslcommerzPlugin: NSObject, FlutterPlugin,SSLCommerzDelegate {
    public func sdkClosed(reason: String) {
        let alertController = UIAlertController(title: "",
             message: reason,preferredStyle: .alert)

       let model = ClosedModel(status: "Closed", message: reason)
        do{
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(model)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            result?(json)
        }catch{
            let alertController = UIAlertController(title: "",
                 message: "Something went wrong!",preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                      alertController.addAction(defaultAction)
            UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
       
    }
    
   public func transactionCompleted(withTransactionData transactionData: TransactionDetails?) {
       do{
           let jsonEncoder = JSONEncoder()
           let jsonData = try jsonEncoder.encode(transactionData)
           let json = String(data: jsonData, encoding: String.Encoding.utf8)
           result?(json)
       }catch{
           let alertController = UIAlertController(title: "",
                message: "Something went wrong!",preferredStyle: .alert)

           let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                     alertController.addAction(defaultAction)
           UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
       }

    }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_sslcommerz", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterSslcommerzPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
 var result : FlutterResult?
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    // result( "iOS " + UIDevice.current.systemVersion + call.method)
     if(call.method.elementsEqual("initiateSSLCommerz")){
        if let arguments = call.arguments as? String , let data = arguments.data(using: .utf8){
                do {
                    print(arguments)
                    let dataRes = try JSONDecoder().decode(FlutterInputDataModel.self, from: data)
                    let datadict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                   
                   
                    let helper = FutterToSwiftDataHelper(flutterData: dataRes)
                    let sslCommerz = SSLCommerz.init(integrationInformation: helper.integrationInformation)
                    sslCommerz.delegate = self
                    sslCommerz.customerInformation = helper.customerInformation
                    sslCommerz.emiInformation = helper.emiInformation
                    sslCommerz.shipmentInformation = helper.shipmentInformation
                    sslCommerz.productInformation = helper.productInformation
                    if let additionalDict = datadict?["sslcAdditionalInitializer"] as? [String: Any], let extras =  additionalDict["extras"] as? [String:String]{
                        sslCommerz.additionalInformation = helper.additionalInformation
                        sslCommerz.additionalInformation?.extras = []
                        extras.forEach { (key,value) in
                            sslCommerz.additionalInformation?.extras?.append((key: key, value: value))
                        }
                        
                    }else{
                        sslCommerz.additionalInformation = helper.additionalInformation
                    }
                    let controller : FlutterViewController = UIApplication.shared.keyWindow?.rootViewController as! FlutterViewController
                    sslCommerz.start(in: controller, shouldRunInTestMode: dataRes.initializer?.sdkType?.uppercased() == "TESTBOX")
                    
                    self.result = result
                } catch let error {
                    let alertController = UIAlertController(title: "",
                                                            message: error.localizedDescription,
                                                            preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
      }
  }
}
