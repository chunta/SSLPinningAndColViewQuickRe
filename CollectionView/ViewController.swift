//
//  ViewController.swift
//  CollectionView
//
//  Created by Rex Chen on 2024/4/2.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    private let list = ["a", "b", "c", "d"]
    
    let space = 8.0
    
    // var session: URLSession!
    
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView();
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
        
        let url = URL(string: "https://45.55.135.116:3000/test")!
        
        for i in 0..<100 {
            let delay = DispatchTimeInterval.seconds(i)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.fetchDataTask(with: url)
            }
        }
    }
    
    func fetchDataTask(with url: URL) {
        session.dataTask(with: url) { data, response, error in
            if let data = data,
               let content = String(data: data, encoding: .utf8) {
                print(content)
            }
        }.resume()
    }
    
    struct CertificateHandler {
        
        static let certificates: [Data] = {
            if let url = Bundle.main.url(forResource: "cert", withExtension: "der"),
               let data = try? Data(contentsOf: url) {
                return [data]
            }
            return []
        }()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
#if USE_SSL_PINNING_CERTIFICATE
        // Check for certificates count in serverTrust if it's >0 then only proceed
        guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Get the certificates from SecTrustCopyCertificateChain and extract first certificate
        guard let certificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let certificate = certificates.first else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Convert certificate to Data
        let data = SecCertificateCopyData(certificate) as Data
        
        // Check if our certificate list contains data
        if CertificateHandler.certificates.contains(data) {
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        } else {
            // Cancel the Authentication Challenge
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
#else
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
            
        }
#endif
    }
    
    private func setUpCollectionView() {
        collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
        cell.testTitle.text = list[indexPath.row]
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        print("UICollectionViewDelegateFlowLayout is called")
        return CGSize(width: (view.bounds.width - space * 3) * 0.5, height: 200)
        
    }
}

