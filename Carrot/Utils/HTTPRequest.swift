//
//  HTTPRequest.swift
//  SwiftDK
//
//  Created by ebamboo on 2021/11/19.
//

import Alamofire
import KakaJSON

// MARK: - HTTP 协议

/// 服务器返回的数据 data 类型
enum DataType {
    case any
    case model(modelType: Convertible.Type)
    case modelArray(modelType: Convertible.Type)
}

protocol HTTP {
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
    /// 标明服务器返回的数据类型
    /// 用于解析服务器返回的数据
    var responseDataType: DataType { get }
}

// MARK: - HTTPRequest 公共方法

struct HTTPRequest {
    /// 响应对象模型
    struct ResponseModel: Convertible {
        var success: Bool!
        var code: Int!
        var message: String?
        var data: Any?
    }
    /// 网络任务错误
    struct MessageData {
        private (set) var rawValue: String
        static let networkError = MessageData(rawValue: "未能连接服务器")
        static let exceptionData = MessageData(rawValue: "服务器返回的数据异常")
        static let noneMessage = MessageData(rawValue: "服务器未返回错误说明")
    }
    /// 网络任务结果
    enum Result {
        case success(data: Any?, headers: [String: Any]?)
        case failure(message: MessageData)
    }
    /// 网络任务取消回调
    typealias CancelHandler = () -> Void
    /// 网络任务结束回调
    typealias CompletionHandler = (_ result: Result) -> Void
    /// 上传文件数据模型
    struct UploadFileModel {
        /// 文件资源本身使用 URL 或者 Data 表示
        /// 两个属性值都为 nil 则不上传该文件
        /// 文件所在路径（本地）
        /// 文件对应的二进制数据
        var url: URL?
        var data: Data?
        /// 文件字段名
        var name: String
        /// 文件名
        var fileName: String
        /// 文件对应的 MIME Type
        /// mp3: "audio/mp3"
        /// mp4: "video/mp4"
        /// png: "image/png"
        /// jpe\jpeg\jpg: "image/jpeg"
        /// pdf: "application/pdf"
        /// text\txt: "text/plain"
        var mimeType: String
    }
    /// 下载文件存储路径配置
    typealias Destination = (_ fileName: String) -> URL
    /// 任务进度回调
    typealias ProgressHandler = (_ progress: Progress) -> Void
}

extension HTTPRequest {
    /// data request
    static func dataRequest(
        api: HTTP,
        cancelHandler: CancelHandler? = nil,
        completionHandler: @escaping CompletionHandler
    ) -> DataRequest {
        printRequest(api: api)
        let task = AF.request(api.url, method: api.method, parameters: api.parameters, encoding: api.encoding, headers: HTTPHeaders(api.headers))
        task.responseData { response in
            printResponse(headers: response.response?.allHeaderFields as? [String: Any], result: response.result)
            parseResponse(api: api, headers: response.response?.allHeaderFields as? [String: Any], result: response.result, cancelHandler: cancelHandler, completionHandler: completionHandler)
        }
        return task
    }
    /// upload request
    static func uploadRequest(
        api: HTTP,
        files: [UploadFileModel],
        progressHandler: @escaping ProgressHandler,
        cancelHandler: CancelHandler? = nil,
        completionHandler: @escaping CompletionHandler
    ) -> UploadRequest {
        printRequest(api: api)
        let task = AF.upload(multipartFormData: { formData in
            for (key, value) in api.parameters as! [String: String] {
                formData.append(value.data(using: .utf8)!, withName: key)
            }
            for file in files {
                if file.url != nil {
                    formData.append(file.url!, withName: file.name, fileName: file.fileName, mimeType: file.mimeType)
                    continue
                }
                if file.data != nil {
                    formData.append(file.data!, withName: file.name, fileName: file.fileName, mimeType: file.mimeType)
                    continue
                }
            }
        }, to: api.url, headers: HTTPHeaders(api.headers))
        task.uploadProgress(closure: progressHandler)
        return task
    }
    /// download request
    static func downloadRequest(
        api: HTTP,
        to destination: Destination? = nil,
        with resumeData: Data? = nil,
        progressHandler: @escaping ProgressHandler,
        cancelHandler: CancelHandler? = nil,
        completionHandler: @escaping CompletionHandler
    ) -> DownloadRequest {
        printRequest(api: api)
        let task: DownloadRequest!
        if resumeData == nil {
            task = AF.download(api.url, parameters: api.parameters, headers: HTTPHeaders(api.headers), to:  { temporaryURL, _ in
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
        return task
    }
}

// MARK: - HTTPRequest 私有方法

/// print debug information
extension HTTPRequest {
    /// 打印请求数据
    static func printRequest(api: HTTP) {
        #if DEBUG
        print("url = \(api.url)")
        let headersData = try! JSONSerialization.data(withJSONObject: api.headers, options: .prettyPrinted)
        let headersString = String(data: headersData, encoding: .utf8)!
        print("headers = \(headersString)")
        let parametersData = try! JSONSerialization.data(withJSONObject: api.parameters, options: .prettyPrinted)
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
            guard let responseModel = responseData.kj.model(ResponseModel.self) else {
                print("responseError = 解析响应对象失败")
                return
            }
            let responseString = responseModel.kj.JSONString(prettyPrinted: true)
            print("responseJSON = \(responseString)")
        case .failure(let error):
            print("responseError = \(error.localizedDescription)")
        }
        #endif
    }
}

/// parse response
extension HTTPRequest {
    static func parseResponse(
        api: HTTP,
        headers: [String: Any]?,
        result: Swift.Result<Data, AFError>,
        cancelHandler: CancelHandler? = nil,
        completionHandler: @escaping CompletionHandler
    ) {
        switch result {
        case .success(let responseData):
            // 解析 responseModel
            guard let responseModel = responseData.kj.model(ResponseModel.self) else {
                completionHandler(.failure(message: .exceptionData))
                return
            }
            // 解析 data 数据
            if responseModel.success {
                switch api.responseDataType {
                case .any:
                    completionHandler(.success(data: responseModel.data, headers: headers))
                case .model(modelType: let modelType):
                    guard let data = responseModel.data as? [String: Any] else {
                        completionHandler(.failure(message: .exceptionData))
                        return
                    }
                    completionHandler(.success(data: model(from: data, type: modelType), headers: headers))
                case .modelArray(modelType: let modelType):
                    guard let data = responseModel.data as? [Any] else {
                        completionHandler(.failure(message: .exceptionData))
                        return
                    }
                    completionHandler(.success(data: modelArray(from: data, type: modelType), headers: headers))
                }
            } else {
                guard let message = responseModel.message else {
                    completionHandler(.failure(message: .noneMessage))
                    return
                }
                completionHandler(.failure(message: MessageData(rawValue: message)))
            }
        case .failure(let error):
            switch error {
            case .explicitlyCancelled:
                cancelHandler?()
            case .responseSerializationFailed:
                completionHandler(.failure(message: .exceptionData))
            default:
                completionHandler(.failure(message: .networkError))
            }
        }
    }
}
