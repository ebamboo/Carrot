//
//  Created by ebamboo on 2021/11/19.
//

import Foundation
import Alamofire

protocol HTTPRequest {
    
    /// method
    var method: HTTP.Method { get }
    /// url
    var url: String { get }
    
    /// headers
    var headers: [String: String] { get }
    
    /// parameters
    var parameters: [String: Any] { get }
    /// parameters encoding
    var encoding: HTTP.Encoding { get }
    
}

struct HTTPResponse {
    
    /// 响应头
    let headers: [String: Any]?
    
    /// 响应体
    let body: Data
    
}

enum HTTPError: Error {
   
    /// 取消
    case cancel
    /// 第三方网络库错误
    case library(message: String)
    
    /// 服务器返回的数据异常
    case exceptionData
    /// 服务器返回的错误说明
    case error(message: String)
    /// 服务器没有返回错误说明
    case noneMessage
 
    /// 错误说明
    var localizedDescription: String {
        switch self {
        case .cancel:
            return "任务已取消"
        case .library(let message):
            return message
        case .exceptionData:
            return "服务器返回的数据异常"
        case .error(let message):
            return message
        case .noneMessage:
            return "服务器未返回错误说明"
        }
    }
    
}

struct HTTP {

    ///
    /// HTTP 请求方法
    ///
    enum Method {
        case get
        case post
        case delete
        case put
    }
 
    ///
    /// HTTP 参数编码方式
    ///
    enum Encoding {
        case json
        case url
    }
    
    ///
    /// 上传文件数据模型
    ///
    /// name 要严格按照后端要求传入；
    /// fileName 无特殊要求一般可以随意传入；
    /// mimeType 表示文件对应的 MIME Type；
    /// 必要时可使用 Alamofire 中根据拓展名获取 MIME Type 方法；
    ///
    struct UploadFileModel {
        init(data: Data, name: String, fileName: String? = nil, mimeType: String? = nil) {
            self.url = nil
            self.data = data
            self.name = name
            self.fileName = fileName
            self.mimeType = mimeType
        }
        init(url: URL, name: String, fileName: String, mimeType: String) {
            self.url = url
            self.data = nil
            self.name = name
            self.fileName = fileName
            self.mimeType = mimeType
        }
        init(url: URL, name: String) {
            self.url = url
            self.data = nil
            self.name = name
            self.fileName = nil
            self.mimeType = nil
        }
        /// 文件资源本身使用 URL 或者 Data 表示；
        /// 两个属性值都为 nil 则不上传该文件；
        let url: URL?
        let data: Data?
        /// 文件字段名
        let name: String
        /// 文件名
        let fileName: String?
        /// 文件对应的 MIME Type；
        /// mp3: "audio/mp3"
        /// mp4: "video/mp4"
        /// png: "image/png"
        /// jpe\jpeg\jpg: "image/jpeg"
        /// pdf: "application/pdf"
        /// text\txt: "text/plain"
        let mimeType: String?
    }
    
    ///
    /// 下载文件存储路径配置；
    /// 可根据实际情况决定是否使用回调中的文件名 fileName；
    /// 该回调返回一个文件存储位置；
    ///
    typealias DownloadDestination = (_ fileName: String) -> URL
    
}

extension HTTP {
    
    // MARK: - 普通数据请求
    
    /// data request
    @discardableResult static func dataRequest(
        _ request: HTTPRequest,
        completionHandler: @escaping (_ result: Result<HTTPResponse, HTTPError>) -> Void
    ) -> DataRequest {
#if DEBUG
        printRequest(request)
#endif
        let method: HTTPMethod = {
            switch request.method {
            case .get:
                return HTTPMethod.get
            case .post:
                return HTTPMethod.post
            case .delete:
                return HTTPMethod.delete
            case .put:
                return HTTPMethod.put
            }
        }()
        let encoding: ParameterEncoding = {
            switch request.encoding {
            case .json:
                return JSONEncoding.default
            case .url:
                return URLEncoding.default
            }
        }()
        let task = AF.request(request.url, method: method, parameters: request.parameters, encoding: encoding, headers: HTTPHeaders(request.headers))
        task.responseData { response in
#if DEBUG
            printResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result)
#endif
            let result: Result<HTTPResponse, HTTPError> = {
                switch response.result {
                case .success(let data):
                    return .success(HTTPResponse(headers: response.response?.allHeaderFields as? [String: Any], body: data))
                case .failure(let error):
                    switch error {
                    case .explicitlyCancelled:
                        return .failure(.cancel)
                    case .responseSerializationFailed:
                        return .failure(.exceptionData)
                    default:
                        return .failure(.library(message: error.errorDescription ?? "网络库未返回错误说明"))
                    }
                }
            }()
            completionHandler(result)
        }
        return task
    }
    
    // MARK: - 上传文件
    
    /// upload request
    @discardableResult static func uploadRequest(
        _ request: HTTPRequest,
        files: [UploadFileModel],
        progressHandler: @escaping (_ progress: Progress) -> Void = { _ in },
        completionHandler: @escaping (_ result: Result<HTTPResponse, HTTPError>) -> Void
    ) -> UploadRequest {
#if DEBUG
        printRequest(request)
#endif
        let task = AF.upload(multipartFormData: { formData in
            for (key, value) in request.parameters as! [String: String] {
                formData.append(value.data(using: .utf8)!, withName: key)
            }
            files.forEach { file in
                if file.data != nil {
                    formData.append(file.data!, withName: file.name, fileName: file.fileName, mimeType: file.mimeType)
                } else if file.mimeType != nil {
                    formData.append(file.url!, withName: file.name, fileName: file.fileName!, mimeType: file.mimeType!)
                } else {
                    formData.append(file.url!, withName: file.name)
                }
            }
        }, to: request.url, headers: HTTPHeaders(request.headers))
        task.uploadProgress(closure: progressHandler)
        task.responseData { response in
#if DEBUG
            printResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result)
#endif
            let result: Result<HTTPResponse, HTTPError> = {
                switch response.result {
                case .success(let data):
                    return .success(HTTPResponse(headers: response.response?.allHeaderFields as? [String: Any], body: data))
                case .failure(let error):
                    switch error {
                    case .explicitlyCancelled:
                        return .failure(.cancel)
                    case .responseSerializationFailed:
                        return .failure(.exceptionData)
                    default:
                        return .failure(.library(message: error.errorDescription ?? "网络库未返回错误说明"))
                    }
                }
            }()
            completionHandler(result)
        }
        return task
    }
    
    // MARK: - 下载文件
    
    /// download request
    @discardableResult static func downloadRequest(
        _ request: HTTPRequest,
        with resumeData: Data? = nil,
        to destination: DownloadDestination? = nil,
        progressHandler: @escaping (_ progress: Progress) -> Void = { _ in },
        completionHandler: @escaping (_ result: Result<HTTPResponse, HTTPError>) -> Void
    ) -> DownloadRequest {
#if DEBUG
        printRequest(request)
#endif
        let task: DownloadRequest!
        if resumeData == nil {
            task = AF.download(request.url, parameters: request.parameters, headers: HTTPHeaders(request.headers), to:  { temporaryURL, _ in
                if destination == nil {
                    let fileName = "Alamofire_\(temporaryURL.lastPathComponent)"
                    let fileURL = temporaryURL.deletingLastPathComponent().appendingPathComponent(fileName)
                    return (fileURL, [])
                } else {
                    let fileName = temporaryURL.lastPathComponent
                    return (destination!(fileName), [.createIntermediateDirectories, .removePreviousFile])
                }
            })
        } else {
            task = AF.download(resumingWith: resumeData!) { temporaryURL, response in
                if destination == nil {
                    let fileName = "Alamofire_\(temporaryURL.lastPathComponent)"
                    let fileURL = temporaryURL.deletingLastPathComponent().appendingPathComponent(fileName)
                    return (fileURL, [])
                } else {
                    let fileName = temporaryURL.lastPathComponent
                    return (destination!(fileName), [.createIntermediateDirectories, .removePreviousFile])
                }
            }
        }
        task.downloadProgress(closure: progressHandler)
        task.responseData { response in
#if DEBUG
            printResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result)
#endif
            let result: Result<HTTPResponse, HTTPError> = {
                switch response.result {
                case .success(let data):
                    return .success(HTTPResponse(headers: response.response?.allHeaderFields as? [String: Any], body: data))
                case .failure(let error):
                    switch error {
                    case .explicitlyCancelled:
                        return .failure(.cancel)
                    case .responseSerializationFailed:
                        return .failure(.exceptionData)
                    default:
                        return .failure(.library(message: error.errorDescription ?? "网络库未返回错误说明"))
                    }
                }
            }()
            completionHandler(result)
        }
        return task
    }
    
}

private extension HTTP {
    
    /// 打印请求数据
    static func printRequest(_ request: HTTPRequest) {
        print("url = \(request.method) \(request.url)")
        let headersData = try! JSONSerialization.data(withJSONObject: request.headers, options: .prettyPrinted)
        let headersString = String(data: headersData, encoding: .utf8)!
        print("headers = \(headersString)")
        let parametersData = try! JSONSerialization.data(withJSONObject: request.parameters, options: .prettyPrinted)
        let parametersString = String(data: parametersData, encoding: .utf8)!
        print("parameters = \(parametersString)")
    }
    
    /// 打印响应数据
    static func printResponse(headers: [String: Any]?, result: Result<Data, AFError>) {
        if headers == nil {
            print("responseHeaders = null")
        } else {
            let responseHeadersData = try! JSONSerialization.data(withJSONObject: headers!, options: .prettyPrinted)
            let responseHeadersString = String(data: responseHeadersData, encoding: .utf8)!
            print("responseHeaders = \(responseHeadersString)")
        }
        switch result {
        case .success(let responseData):
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: [])
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "解析响应对象失败"
                print("responseObject = \(jsonString)")
            } catch {
                print("responseObject = 解析响应对象失败")
            }
        case .failure(let error):
            print("responseObject = \(error.errorDescription ?? "alamofire未知错误")")
        }
    }
    
}
