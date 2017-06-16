//
//  NetworkManager.swift
//  Cenarius
//
//  Created by M on 2017/4/19.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import Alamofire

open class NetworkManager: SessionManager {
    
    open static let defaultManager: NetworkManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = NetworkManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 60
        return NetworkManager(configuration: configuration)
    }()
    
    // MARK: - Data Request
    
    /// Creates a `DataRequest` to retrieve the contents of the specified `url`, `method`, `parameters`, `encoding`
    /// and `headers`.
    ///
    /// - parameter url:        The URL.
    /// - parameter method:     The HTTP method. `.get` by default.
    /// - parameter parameters: The parameters. `nil` by default.
    /// - parameter encoding:   The parameter encoding. `URLEncoding.default` by default.
    /// - parameter headers:    The HTTP headers. `nil` by default.
    ///
    /// - returns: The created `DataRequest`.
    @discardableResult
    open override func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest
    {
        var urlString = url
        var headersFinal = headers ?? HTTPHeaders()
        var encodingFinal = encoding
        do {
            urlString = try url.asURL().absoluteString
            if encoding is JSONEncoding {
                if headersFinal[OpenApi.contentTypeKey] == nil {
                    headersFinal[OpenApi.contentTypeKey] = OpenApi.contentTypeValue
                }
            }
            else if headersFinal[OpenApi.contentTypeKey] == OpenApi.contentTypeValue {
                encodingFinal = JSONEncoding.default
            }
            urlString = OpenApi.sign(url: urlString as! String, parameters: parameters, headers: headersFinal)
        } catch {
            
        }
        return super.request(urlString, method: method, parameters: parameters, encoding: encodingFinal, headers: headersFinal)
    }
    
    /// Creates a `DataRequest` to retrieve the contents of a URL based on the specified `urlRequest`.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter urlRequest: The URL request.
    ///
    /// - returns: The created `DataRequest`.
    open override func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        return super.request(urlRequest)
    }
    
    // MARK: - Download Request
    
    // MARK: URL Request
    
    /// Creates a `DownloadRequest` to retrieve the contents the specified `url`, `method`, `parameters`, `encoding`,
    /// `headers` and save them to the `destination`.
    ///
    /// If `destination` is not specified, the contents will remain in the temporary location determined by the
    /// underlying URL session.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter url:         The URL.
    /// - parameter method:      The HTTP method. `.get` by default.
    /// - parameter parameters:  The parameters. `nil` by default.
    /// - parameter encoding:    The parameter encoding. `URLEncoding.default` by default.
    /// - parameter headers:     The HTTP headers. `nil` by default.
    /// - parameter destination: The closure used to determine the destination of the downloaded file. `nil` by default.
    ///
    /// - returns: The created `DownloadRequest`.
    @discardableResult
    open override func download(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        to destination: DownloadRequest.DownloadFileDestination? = nil)
        -> DownloadRequest
    {
        return super.download(url, method: method, parameters: parameters, encoding: encoding, headers: headers, to: destination)
    }
    
    /// Creates a `DownloadRequest` to retrieve the contents of a URL based on the specified `urlRequest` and save
    /// them to the `destination`.
    ///
    /// If `destination` is not specified, the contents will remain in the temporary location determined by the
    /// underlying URL session.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter urlRequest:  The URL request
    /// - parameter destination: The closure used to determine the destination of the downloaded file. `nil` by default.
    ///
    /// - returns: The created `DownloadRequest`.
    @discardableResult
    open override func download(
        _ urlRequest: URLRequestConvertible,
        to destination: DownloadRequest.DownloadFileDestination? = nil)
        -> DownloadRequest
    {
        return super.download(urlRequest, to: destination)
    }
    
    // MARK: Resume Data
    
    /// Creates a `DownloadRequest` from the `resumeData` produced from a previous request cancellation to retrieve
    /// the contents of the original request and save them to the `destination`.
    ///
    /// If `destination` is not specified, the contents will remain in the temporary location determined by the
    /// underlying URL session.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// On the latest release of all the Apple platforms (iOS 10, macOS 10.12, tvOS 10, watchOS 3), `resumeData` is broken
    /// on background URL session configurations. There's an underlying bug in the `resumeData` generation logic where the
    /// data is written incorrectly and will always fail to resume the download. For more information about the bug and
    /// possible workarounds, please refer to the following Stack Overflow post:
    ///
    ///    - http://stackoverflow.com/a/39347461/1342462
    ///
    /// - parameter resumeData:  The resume data. This is an opaque data blob produced by `URLSessionDownloadTask`
    ///                          when a task is cancelled. See `URLSession -downloadTask(withResumeData:)` for
    ///                          additional information.
    /// - parameter destination: The closure used to determine the destination of the downloaded file. `nil` by default.
    ///
    /// - returns: The created `DownloadRequest`.
    @discardableResult
    open override func download(
        resumingWith resumeData: Data,
        to destination: DownloadRequest.DownloadFileDestination? = nil)
        -> DownloadRequest
    {
        return super.download(resumingWith: resumeData, to: destination)
    }
    
    // MARK: - Upload Request
    
    // MARK: File
    
    /// Creates an `UploadRequest` from the specified `url`, `method` and `headers` for uploading the `file`.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter file:    The file to upload.
    /// - parameter url:     The URL.
    /// - parameter method:  The HTTP method. `.post` by default.
    /// - parameter headers: The HTTP headers. `nil` by default.
    ///
    /// - returns: The created `UploadRequest`.
    @discardableResult
    open override func upload(
        _ fileURL: URL,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil)
        -> UploadRequest
    {
        return super.upload(fileURL, to: url, method: method, headers: headers)
    }
    
    /// Creates a `UploadRequest` from the specified `urlRequest` for uploading the `file`.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter file:       The file to upload.
    /// - parameter urlRequest: The URL request.
    ///
    /// - returns: The created `UploadRequest`.
    @discardableResult
    open override func upload(_ fileURL: URL, with urlRequest: URLRequestConvertible) -> UploadRequest {
        return super.upload(fileURL, with: urlRequest)
    }
    
    // MARK: Data
    
    /// Creates an `UploadRequest` from the specified `url`, `method` and `headers` for uploading the `data`.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter data:    The data to upload.
    /// - parameter url:     The URL.
    /// - parameter method:  The HTTP method. `.post` by default.
    /// - parameter headers: The HTTP headers. `nil` by default.
    ///
    /// - returns: The created `UploadRequest`.
    @discardableResult
    open override func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil)
        -> UploadRequest
    {
        return super.upload(data, to: url, method: method, headers: headers)
    }
    
    /// Creates an `UploadRequest` from the specified `urlRequest` for uploading the `data`.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter data:       The data to upload.
    /// - parameter urlRequest: The URL request.
    ///
    /// - returns: The created `UploadRequest`.
    @discardableResult
    open override func upload(_ data: Data, with urlRequest: URLRequestConvertible) -> UploadRequest {
        return super.upload(data, with: urlRequest)
    }
    
    // MARK: InputStream
    
    /// Creates an `UploadRequest` from the specified `url`, `method` and `headers` for uploading the `stream`.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter stream:  The stream to upload.
    /// - parameter url:     The URL.
    /// - parameter method:  The HTTP method. `.post` by default.
    /// - parameter headers: The HTTP headers. `nil` by default.
    ///
    /// - returns: The created `UploadRequest`.
    @discardableResult
    open override func upload(
        _ stream: InputStream,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil)
        -> UploadRequest
    {
        return super.upload(stream, to: url, method: method, headers: headers)
    }
    
    /// Creates an `UploadRequest` from the specified `urlRequest` for uploading the `stream`.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter stream:     The stream to upload.
    /// - parameter urlRequest: The URL request.
    ///
    /// - returns: The created `UploadRequest`.
    @discardableResult
    open override func upload(_ stream: InputStream, with urlRequest: URLRequestConvertible) -> UploadRequest {
        return super.upload(stream, with: urlRequest)
    }
    
    // MARK: MultipartFormData
    
    /// Encodes `multipartFormData` using `encodingMemoryThreshold` and calls `encodingCompletion` with new
    /// `UploadRequest` using the `url`, `method` and `headers`.
    ///
    /// It is important to understand the memory implications of uploading `MultipartFormData`. If the cummulative
    /// payload is small, encoding the data in-memory and directly uploading to a server is the by far the most
    /// efficient approach. However, if the payload is too large, encoding the data in-memory could cause your app to
    /// be terminated. Larger payloads must first be written to disk using input and output streams to keep the memory
    /// footprint low, then the data can be uploaded as a stream from the resulting file. Streaming from disk MUST be
    /// used for larger payloads such as video content.
    ///
    /// The `encodingMemoryThreshold` parameter allows Alamofire to automatically determine whether to encode in-memory
    /// or stream from disk. If the content length of the `MultipartFormData` is below the `encodingMemoryThreshold`,
    /// encoding takes place in-memory. If the content length exceeds the threshold, the data is streamed to disk
    /// during the encoding process. Then the result is uploaded as data or as a stream depending on which encoding
    /// technique was used.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
    /// - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
    ///                                      `multipartFormDataEncodingMemoryThreshold` by default.
    /// - parameter url:                     The URL.
    /// - parameter method:                  The HTTP method. `.post` by default.
    /// - parameter headers:                 The HTTP headers. `nil` by default.
    /// - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
    open override func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        encodingCompletion: ((MultipartFormDataEncodingResult) -> Void)?)
    {
        return super.upload(multipartFormData: multipartFormData, usingThreshold: encodingMemoryThreshold, to: url, method: method, headers: headers, encodingCompletion: encodingCompletion)
    }
    
    /// Encodes `multipartFormData` using `encodingMemoryThreshold` and calls `encodingCompletion` with new
    /// `UploadRequest` using the `urlRequest`.
    ///
    /// It is important to understand the memory implications of uploading `MultipartFormData`. If the cummulative
    /// payload is small, encoding the data in-memory and directly uploading to a server is the by far the most
    /// efficient approach. However, if the payload is too large, encoding the data in-memory could cause your app to
    /// be terminated. Larger payloads must first be written to disk using input and output streams to keep the memory
    /// footprint low, then the data can be uploaded as a stream from the resulting file. Streaming from disk MUST be
    /// used for larger payloads such as video content.
    ///
    /// The `encodingMemoryThreshold` parameter allows Alamofire to automatically determine whether to encode in-memory
    /// or stream from disk. If the content length of the `MultipartFormData` is below the `encodingMemoryThreshold`,
    /// encoding takes place in-memory. If the content length exceeds the threshold, the data is streamed to disk
    /// during the encoding process. Then the result is uploaded as data or as a stream depending on which encoding
    /// technique was used.
    ///
    /// If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.
    ///
    /// - parameter multipartFormData:       The closure used to append body parts to the `MultipartFormData`.
    /// - parameter encodingMemoryThreshold: The encoding memory threshold in bytes.
    ///                                      `multipartFormDataEncodingMemoryThreshold` by default.
    /// - parameter urlRequest:              The URL request.
    /// - parameter encodingCompletion:      The closure called when the `MultipartFormData` encoding is complete.
    open override func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold,
        with urlRequest: URLRequestConvertible,
        encodingCompletion: ((MultipartFormDataEncodingResult) -> Void)?)
    {
        return super.upload(multipartFormData: multipartFormData, usingThreshold: encodingMemoryThreshold, with: urlRequest, encodingCompletion: encodingCompletion)
    }
    
}
