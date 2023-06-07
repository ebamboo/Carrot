//
//  Created by ebamboo on 2021/11/19.
//

import Foundation
import Alamofire

// MARK: - HTTPRequest 协议

protocol HTTPRequest {
    /// method
    var method: HTTPMethod { get }
    /// url
    var url: String { get }
    /// headers
    var headers: [String: String] { get }
    /// parameters encoding
    var encoding: ParameterEncoding { get }
    /// parameters
    var parameters: [String: Any] { get }
}

// MARK: - HTTP 公共方法

struct HTTP {
    ///
    /// 上传文件数据模型
    ///
    /// name 要严格按照后端要求传入，fileName 无特殊要求一般可以随意传入
    ///
    /// mimeType 表示文件对应的 MIME Type
    /// 必要时可使用 Alamofire 中根据拓展名获取 MIME Type 方法
    /// mp3: "audio/mp3"
    /// mp4: "video/mp4"
    /// png: "image/png"
    /// jpe\jpeg\jpg: "image/jpeg"
    /// pdf: "application/pdf"
    /// text\txt: "text/plain"
    ///
    enum UploadFileModel {
        case data(_ data: Data, name: String, fileName: String? = nil, mimeType: String? = nil)
        case url(_ url: URL, name: String, fileName: String, mimeType: String)
        case automaticUrl(_ url: URL, name: String)
    }
    /// 下载文件存储路径配置
    typealias DownloadDestination = (_ fileName: String) -> URL
    /// 网络任务结果
    enum Result {
        struct MessageData {
            private (set) var rawValue: String
            static let networkError = MessageData(rawValue: "未能连接服务器")
            static let exceptionData = MessageData(rawValue: "服务器返回的数据异常")
            static let noneMessage = MessageData(rawValue: "服务器未返回错误说明")
        }
        case success(data: Any?, headers: [String: Any]?)
        case failure(message: MessageData)
        case cancel
    }
}

extension HTTP {
    /// data request
    @discardableResult static func dataRequest(
        _ request: HTTPRequest,
        completionHandler: @escaping (_ result: Result) -> Void
    ) -> DataRequest {
        printRequest(request)
        let task = AF.request(request.url, method: request.method, parameters: request.parameters, encoding: request.encoding, headers: HTTPHeaders(request.headers))
        task.responseData { response in
            printResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result)
            parseResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result, completionHandler: completionHandler)
        }
        return task
    }
    /// upload request
    @discardableResult static func uploadRequest(
        _ request: HTTPRequest,
        files: [UploadFileModel],
        progressHandler: @escaping (_ progress: Progress) -> Void = { _ in },
        completionHandler: @escaping (_ result: Result) -> Void
    ) -> UploadRequest {
        printRequest(request)
        let task = AF.upload(multipartFormData: { formData in
            for (key, value) in request.parameters as! [String: String] {
                formData.append(value.data(using: .utf8)!, withName: key)
            }
            files.forEach { file in
                switch file {
                case .data(let data, let name, let fileName, let mimeType):
                    formData.append(data, withName: name, fileName: fileName, mimeType: mimeType)
                case .url(let url, let name, let fileName, let mimeType):
                    formData.append(url, withName: name, fileName: fileName, mimeType: mimeType)
                case .automaticUrl(let url, let name):
                    formData.append(url, withName: name)
                }
            }
        }, to: request.url, headers: HTTPHeaders(request.headers))
        task.uploadProgress(closure: progressHandler)
        task.responseData { response in
            printResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result)
            parseResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result, completionHandler: completionHandler)
        }
        return task
    }
    /// download request
    @discardableResult static func downloadRequest(
        _ request: HTTPRequest,
        with resumeData: Data? = nil,
        to destination: DownloadDestination? = nil,
        progressHandler: @escaping (_ progress: Progress) -> Void = { _ in },
        completionHandler: @escaping (_ result: Result) -> Void
    ) -> DownloadRequest {
        printRequest(request)
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
            printResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result)
            parseResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result, completionHandler: completionHandler)
        }
        return task
    }
}

// MARK: - HTTP 私有方法

private extension HTTP {
    /// 打印请求数据
    static func printRequest(_ request: HTTPRequest) {
        #if DEBUG
        print("url = \(request.url)")
        let headersData = try! JSONSerialization.data(withJSONObject: request.headers, options: .prettyPrinted)
        let headersString = String(data: headersData, encoding: .utf8)!
        print("headers = \(headersString)")
        let parametersData = try! JSONSerialization.data(withJSONObject: request.parameters, options: .prettyPrinted)
        let parametersString = String(data: parametersData, encoding: .utf8)!
        print("parameters = \(parametersString)")
        #endif
    }
    /// 打印响应数据
    static func printResponse(headers: [String: Any]?, result: Swift.Result<Data, AFError>) {
        #if DEBUG
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
            print("responseObject = \(error.localizedDescription)")
        }
        #endif
    }
    /// 解析响应结果
    static func parseResponse(headers: [String: Any]?, result: Swift.Result<Data, AFError>, completionHandler: @escaping (_ result: Result) -> Void) {
        switch result {
        case .success(let responseData):
            // 解析响应对象
            guard
                let jsonObject = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                let success = jsonObject["success"] as? Bool,
                let code = jsonObject["code"] as? Int
            else {
                completionHandler(.failure(message: .exceptionData))
                return
            }
            let message = jsonObject["message"] as? String
            let data = jsonObject["data"]
            // 解析 data 数据
            if success {
                completionHandler(.success(data: data, headers: headers))
            } else {
                let error = message == nil ? .noneMessage : Result.MessageData(rawValue: message!)
                completionHandler(.failure(message: error))
            }
        case .failure(let error):
            switch error {
            case .explicitlyCancelled:
                completionHandler(.cancel)
            case .responseSerializationFailed:
                completionHandler(.failure(message: .exceptionData))
            default:
                completionHandler(.failure(message: .networkError))
            }
        }
    }
}
