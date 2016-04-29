//
//  ViewController.swift
//  servicios1
//
//  Created by Antonio Franco on 17/12/15.
//  Copyright © 2015 José Antonio Franco Cortés. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var nombreLibro: UILabel!
    @IBOutlet weak var autorNombre: UILabel!
    @IBOutlet weak var ingresarISBN: UITextField!
    @IBOutlet weak var resultadoISBN: UITextView!
    @IBOutlet weak var resultadoAutor: UITextView!
    @IBOutlet weak var resultadoImagen: UIImageView!
    
    var nombres = [String]()
    
    func sincrono(){
        let urls = "http://dia.ccm.itesm.mx"
        let url = NSURL(string: urls)
        let datos:NSData? = NSData(contentsOfURL: url!)
        let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
        print(texto!)
    }
    
    
    func consultaLibro(){
        
        let URLS = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(ingresarISBN.text!)"
        let url = NSURL(string: URLS)
        let datos = NSData(contentsOfURL: url!)

        
        do{
            
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let dico1 = json as! NSDictionary
            let dico2 = dico1["ISBN:" + ingresarISBN.text!] as! NSDictionary
            let dico3 = dico2["authors"] as! NSArray
            let dico4 = dico2["title"] as! NSString
            self.resultadoISBN.text = dico4 as String

            if  (dico2["cover"] != nil) {
              let dico5 = dico2["cover"] as! NSDictionary
                let dico6 = dico5["medium"] as! NSString
                let img_url = NSURL(string: dico6 as String)
                let img_datos = NSData(contentsOfURL: img_url!)
                if (img_datos != nil) {
                    if let imagen = UIImage(data: img_datos!) {
                        self.resultadoImagen.image = imagen
                    }
                }
            } else {
               self.resultadoImagen.image = UIImage(named:"nodisponible")
            }
            
            for elemento in dico3 {
                let nombreAutor = (elemento as! NSDictionary)["name"] as!
                String
                nombres.append(nombreAutor )
            }
            
            if (nombres.count == 1){
                 self.resultadoAutor.text = "\(nombres)\n"
             
                
            }else{
               self.resultadoAutor.text = "\(nombres)\",\n"
             
            }
        }
        catch
        {
            // By default the catch clause defines the variable error as whatever ws thrown
            print("Error is \(error)")
            
        }

        
        
    }
    
    
     func asincrono(){
        
        if let text = ingresarISBN.text {
            let url = NSURL(string : "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(text)")
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                print (NSString(data: data!,
                    encoding: NSUTF8StringEncoding))
                let impresion = NSString(data: data!,
                    encoding: NSUTF8StringEncoding)
                dispatch_async(dispatch_get_main_queue()) {  // GCD
                    self.resultadoISBN.text = impresion as! String // might need a [weak self]
                    
                    
                    
                    
                }
            }
            task.resume()
            

        }
}
    
    
    @IBAction func btnLimpiar(sender: AnyObject) {
        ingresarISBN.text = ""
        resultadoISBN.text = ""
        resultadoImagen.image = nil
        resultadoAutor.text = ""
        nombres = []
    }
    

    @IBAction func realizarActividad(sender: AnyObject) {
        
   
        if isConnectedToNetwork() == true {
            print("Internet connection OK")
                  //asincrono()
            consultaLibro()
        } else {
            print("Internet connection FAILED")

            let mensajeAlerta = UIAlertController(title: "No tienes conexion de internet",
                message: "Asegurate de que tu dispositivo esta conectado a internet" , preferredStyle: .Alert)
            
            let defaultAccion = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil)
            
            mensajeAlerta.addAction(defaultAccion)
            mensajeAlerta.addAction(cancelAction)
            
            presentViewController(mensajeAlerta, animated: true, completion: nil)
            
        }
        
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
     
        ingresarISBN.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

