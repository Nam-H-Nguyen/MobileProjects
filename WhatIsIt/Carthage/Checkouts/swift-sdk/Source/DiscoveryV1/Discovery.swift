/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/
// swiftlint:disable file_length

import Foundation
import RestKit

/**
 The IBM Watson&trade; Discovery Service is a cognitive search and content analytics engine that you can add to
 applications to identify patterns, trends and actionable insights to drive better decision-making. Securely unify
 structured and unstructured data with pre-enriched content, and use a simplified query language to eliminate the need
 for manual filtering of results.
 */
public class Discovery {

    /// The base URL to use when contacting the service.
    public var serviceURL = "https://gateway.watsonplatform.net/discovery/api"

    /// The default HTTP headers for all requests to the service.
    public var defaultHeaders = [String: String]()

    private let session = URLSession(configuration: URLSessionConfiguration.default)
    private var authMethod: AuthenticationMethod
    private let domain = "com.ibm.watson.developer-cloud.DiscoveryV1"
    private let version: String

    /**
     Create a `Discovery` object.

     - parameter username: The username used to authenticate with the service.
     - parameter password: The password used to authenticate with the service.
     - parameter version: The release date of the version of the API to use. Specify the date
       in "YYYY-MM-DD" format.
     */
    public init(username: String, password: String, version: String) {
        self.authMethod = Shared.getAuthMethod(username: username, password: password)
        self.version = version
        Shared.configureRestRequest()
    }

    /**
     Create a `Discovery` object.

     - parameter version: The release date of the version of the API to use. Specify the date
       in "YYYY-MM-DD" format.
     - parameter apiKey: An API key for IAM that can be used to obtain access tokens for the service.
     - parameter iamUrl: The URL for the IAM service.
     */
    public init(version: String, apiKey: String, iamUrl: String? = nil) {
        self.authMethod = Shared.getAuthMethod(apiKey: apiKey, iamURL: iamUrl)
        self.version = version
        Shared.configureRestRequest()
    }

    /**
     Create a `Discovery` object.

     - parameter version: The release date of the version of the API to use. Specify the date
       in "YYYY-MM-DD" format.
     - parameter accessToken: An access token for the service.
     */
    public init(version: String, accessToken: String) {
        self.authMethod = IAMAccessToken(accessToken: accessToken)
        self.version = version
        Shared.configureRestRequest()
    }

    public func accessToken(_ newToken: String) {
        if self.authMethod is IAMAccessToken {
            self.authMethod = IAMAccessToken(accessToken: newToken)
        }
    }

    /**
     If the response or data represents an error returned by the Discovery service,
     then return NSError with information about the error that occured. Otherwise, return nil.

     - parameter data: Raw data returned from the service that may represent an error.
     - parameter response: the URL response returned from the service.
     */
    func errorResponseDecoder(data: Data, response: HTTPURLResponse) -> Error {

        let code = response.statusCode
        do {
            let json = try JSONDecoder().decode([String: JSON].self, from: data)
            var userInfo: [String: Any] = [:]
            if case let .some(.string(message)) = json["error"] {
                userInfo[NSLocalizedDescriptionKey] = message
            }
            if case let .some(.string(description)) = json["description"] {
                userInfo[NSLocalizedRecoverySuggestionErrorKey] = description
            }
            return NSError(domain: domain, code: code, userInfo: userInfo)
        } catch {
            return NSError(domain: domain, code: code, userInfo: nil)
        }
    }

    /**
     Create an environment.

     Creates a new environment for private data. An environment must be created before collections can be created.
     **Note**: You can create only one environment for private data per service instance. An attempt to create another
     environment results in an error.

     - parameter name: Name that identifies the environment.
     - parameter description: Description of the environment.
     - parameter size: Size of the environment. In the Lite plan the default and only accepted value is `LT`, in all
       other plans the default is `S`.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func createEnvironment(
        name: String,
        description: String? = nil,
        size: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Environment) -> Void)
    {
        // construct body
        let createEnvironmentRequest = CreateEnvironmentRequest(name: name, description: description, size: size)
        guard let body = try? JSONEncoder().encode(createEnvironmentRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + "/v1/environments",
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Environment>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     List environments.

     List existing environments for the service instance.

     - parameter name: Show only the environment with the given name.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func listEnvironments(
        name: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (ListEnvironmentsResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let name = name {
            let queryParameter = URLQueryItem(name: "name", value: name)
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + "/v1/environments",
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<ListEnvironmentsResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Get environment info.

     - parameter environmentID: The ID of the environment.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getEnvironment(
        environmentID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Environment) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Environment>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Update an environment.

     Updates an environment. The environment's **name** and  **description** parameters can be changed. You must specify
     a **name** for the environment.

     - parameter environmentID: The ID of the environment.
     - parameter name: Name that identifies the environment.
     - parameter description: Description of the environment.
     - parameter size: Size that the environment should be increased to. Environment size cannot be modified when
       using a Lite plan. Environment size can only increased and not decreased.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func updateEnvironment(
        environmentID: String,
        name: String? = nil,
        description: String? = nil,
        size: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Environment) -> Void)
    {
        // construct body
        let updateEnvironmentRequest = UpdateEnvironmentRequest(name: name, description: description, size: size)
        guard let body = try? JSONEncoder().encode(updateEnvironmentRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "PUT",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Environment>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete environment.

     - parameter environmentID: The ID of the environment.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteEnvironment(
        environmentID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DeleteEnvironmentResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<DeleteEnvironmentResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     List fields across collections.

     Gets a list of the unique fields (and their types) stored in the indexes of the specified collections.

     - parameter environmentID: The ID of the environment.
     - parameter collectionIds: A comma-separated list of collection IDs to be queried against.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func listFields(
        environmentID: String,
        collectionIds: [String],
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (ListCollectionFieldsResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        queryParameters.append(URLQueryItem(name: "collection_ids", value: collectionIds.joined(separator: ",")))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/fields"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<ListCollectionFieldsResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Add configuration.

     Creates a new configuration.
     If the input configuration contains the **configuration_id**, **created**, or **updated** properties, then they are
     ignored and overridden by the system, and an error is not returned so that the overridden fields do not need to be
     removed when copying a configuration.
     The configuration can contain unrecognized JSON fields. Any such fields are ignored and do not generate an error.
     This makes it easier to use newer configuration files with older versions of the API and the service. It also makes
     it possible for the tooling to add additional metadata and information to the configuration.

     - parameter environmentID: The ID of the environment.
     - parameter configuration: Input an object that enables you to customize how your content is ingested and what
       enrichments are added to your data.
       **name** is required and must be unique within the current **environment**. All other properties are optional.
       If the input configuration contains the **configuration_id**, **created**, or **updated** properties, then they
       will be ignored and overridden by the system (an error is not returned so that the overridden fields do not need
       to be removed when copying a configuration).
       The configuration can contain unrecognized JSON fields. Any such fields will be ignored and will not generate an
       error. This makes it easier to use newer configuration files with older versions of the API and the service. It
       also makes it possible for the tooling to add additional metadata and information to the configuration.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func createConfiguration(
        environmentID: String,
        configuration: Configuration,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Configuration) -> Void)
    {
        // construct body
        guard let body = try? JSONEncoder().encode(configuration) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/configurations"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Configuration>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     List configurations.

     Lists existing configurations for the service instance.

     - parameter environmentID: The ID of the environment.
     - parameter name: Find configurations with the given name.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func listConfigurations(
        environmentID: String,
        name: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (ListConfigurationsResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let name = name {
            let queryParameter = URLQueryItem(name: "name", value: name)
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let path = "/v1/environments/\(environmentID)/configurations"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<ListConfigurationsResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Get configuration details.

     - parameter environmentID: The ID of the environment.
     - parameter configurationID: The ID of the configuration.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getConfiguration(
        environmentID: String,
        configurationID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Configuration) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/configurations/\(configurationID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Configuration>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Update a configuration.

     Replaces an existing configuration.
       * Completely replaces the original configuration.
       * The **configuration_id**, **updated**, and **created** fields are accepted in the request, but they are
     ignored, and an error is not generated. It is also acceptable for users to submit an updated configuration with
     none of the three properties.
       * Documents are processed with a snapshot of the configuration as it was at the time the document was submitted
     to be ingested. This means that already submitted documents will not see any updates made to the configuration.

     - parameter environmentID: The ID of the environment.
     - parameter configurationID: The ID of the configuration.
     - parameter configuration: Input an object that enables you to update and customize how your data is ingested and
       what enrichments are added to your data.
       The **name** parameter is required and must be unique within the current **environment**. All other properties
       are optional, but if they are omitted  the default values replace the current value of each omitted property.
       If the input configuration contains the **configuration_id**, **created**, or **updated** properties, they are
       ignored and overridden by the system, and an error is not returned so that the overridden fields do not need to
       be removed when updating a configuration.
       The configuration can contain unrecognized JSON fields. Any such fields are ignored and do not generate an error.
       This makes it easier to use newer configuration files with older versions of the API and the service. It also
       makes it possible for the tooling to add additional metadata and information to the configuration.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func updateConfiguration(
        environmentID: String,
        configurationID: String,
        configuration: Configuration,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Configuration) -> Void)
    {
        // construct body
        guard let body = try? JSONEncoder().encode(configuration) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/configurations/\(configurationID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "PUT",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Configuration>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete a configuration.

     The deletion is performed unconditionally. A configuration deletion request succeeds even if the configuration is
     referenced by a collection or document ingestion. However, documents that have already been submitted for
     processing continue to use the deleted configuration. Documents are always processed with a snapshot of the
     configuration as it existed at the time the document was submitted.

     - parameter environmentID: The ID of the environment.
     - parameter configurationID: The ID of the configuration.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteConfiguration(
        environmentID: String,
        configurationID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DeleteConfigurationResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/configurations/\(configurationID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<DeleteConfigurationResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Test configuration.

     Runs a sample document through the default or your configuration and returns diagnostic information designed to
     help you understand how the document was processed. The document is not added to the index.

     - parameter environmentID: The ID of the environment.
     - parameter configuration: The configuration to use to process the document. If this part is provided, then the
       provided configuration is used to process the document. If the **configuration_id** is also provided (both are
       present at the same time), then request is rejected. The maximum supported configuration size is 1 MB.
       Configuration parts larger than 1 MB are rejected.
       See the `GET /configurations/{configuration_id}` operation for an example configuration.
     - parameter step: Specify to only run the input document through the given step instead of running the input
       document through the entire ingestion workflow. Valid values are `convert`, `enrich`, and `normalize`.
     - parameter configurationID: The ID of the configuration to use to process the document. If the **configuration**
       form part is also provided (both are present at the same time), then the request will be rejected.
     - parameter file: The content of the document to ingest. The maximum supported file size is 50 megabytes. Files
       larger than 50 megabytes is rejected.
     - parameter metadata: If you're using the Data Crawler to upload your documents, you can test a document against
       the type of metadata that the Data Crawler might send. The maximum supported metadata file size is 1 MB. Metadata
       parts larger than 1 MB are rejected.
       Example:  ``` {
         \"Creator\": \"Johnny Appleseed\",
         \"Subject\": \"Apples\"
       } ```.
     - parameter fileContentType: The content type of file.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func testConfigurationInEnvironment(
        environmentID: String,
        configuration: String? = nil,
        step: String? = nil,
        configurationID: String? = nil,
        file: URL? = nil,
        metadata: String? = nil,
        fileContentType: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TestDocument) -> Void)
    {
        // construct body
        let multipartFormData = MultipartFormData()
        if let configuration = configuration {
            if let configurationData = configuration.data(using: .utf8) {
                multipartFormData.append(configurationData, withName: "configuration")
            }
        }
        if let file = file {
            do {
                try multipartFormData.append(file: file, withName: "file")
            } catch {
                failure?(error)
                return
            }
        }
        if let metadata = metadata {
            if let metadataData = metadata.data(using: .utf8) {
                multipartFormData.append(metadataData, withName: "metadata")
            }
        }
        guard let body = try? multipartFormData.toData() else {
            failure?(RestError.encodingError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = multipartFormData.contentType

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let step = step {
            let queryParameter = URLQueryItem(name: "step", value: step)
            queryParameters.append(queryParameter)
        }
        if let configurationID = configurationID {
            let queryParameter = URLQueryItem(name: "configuration_id", value: configurationID)
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let path = "/v1/environments/\(environmentID)/preview"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TestDocument>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Create a collection.

     - parameter environmentID: The ID of the environment.
     - parameter properties: Input an object that allows you to add a collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func createCollection(
        environmentID: String,
        properties: CreateCollectionRequest,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Collection) -> Void)
    {
        // construct body
        guard let body = try? JSONEncoder().encode(properties) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Collection>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     List collections.

     Lists existing collections for the service instance.

     - parameter environmentID: The ID of the environment.
     - parameter name: Find collections with the given name.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func listCollections(
        environmentID: String,
        name: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (ListCollectionsResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let name = name {
            let queryParameter = URLQueryItem(name: "name", value: name)
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<ListCollectionsResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Get collection details.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getCollection(
        environmentID: String,
        collectionID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Collection) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Collection>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Update a collection.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter name: The name of the collection.
     - parameter description: A description of the collection.
     - parameter configurationID: The ID of the configuration in which the collection is to be updated.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func updateCollection(
        environmentID: String,
        collectionID: String,
        name: String,
        description: String? = nil,
        configurationID: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Collection) -> Void)
    {
        // construct body
        let updateCollectionRequest = UpdateCollectionRequest(name: name, description: description, configurationID: configurationID)
        guard let body = try? JSONEncoder().encodeIfPresent(updateCollectionRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "PUT",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Collection>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete a collection.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteCollection(
        environmentID: String,
        collectionID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DeleteCollectionResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<DeleteCollectionResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     List collection fields.

     Gets a list of the unique fields (and their types) stored in the index.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func listCollectionFields(
        environmentID: String,
        collectionID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (ListCollectionFieldsResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/fields"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<ListCollectionFieldsResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Get the expansion list.

     Returns the current expansion list for the specified collection. If an expansion list is not specified, an object
     with empty expansion arrays is returned.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func listExpansions(
        environmentID: String,
        collectionID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Expansions) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/expansions"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Expansions>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Create or update expansion list.

     Create or replace the Expansion list for this collection. The maximum number of expanded terms per collection is
     `500`.
     The current expansion list is replaced with the uploaded content.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter expansions: An array of query expansion definitions.
        Each object in the **expansions** array represents a term or set of terms that will be expanded into other
       terms. Each expansion object can be configured as bidirectional or unidirectional. Bidirectional means that all
       terms are expanded to all other terms in the object. Unidirectional means that a set list of terms can be
       expanded into a second list of terms.
        To create a bi-directional expansion specify an **expanded_terms** array. When found in a query, all items in
       the **expanded_terms** array are then expanded to the other items in the same array.
        To create a uni-directional expansion, specify both an array of **input_terms** and an array of
       **expanded_terms**. When items in the **input_terms** array are present in a query, they are expanded using the
       items listed in the **expanded_terms** array.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func createExpansions(
        environmentID: String,
        collectionID: String,
        expansions: [Expansion],
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Expansions) -> Void)
    {
        // construct body
        let createExpansionsRequest = Expansions(expansions: expansions)
        guard let body = try? JSONEncoder().encode(createExpansionsRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/expansions"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Expansions>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete the expansion list.

     Remove the expansion information for this collection. The expansion list must be deleted to disable query expansion
     for a collection.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteExpansions(
        environmentID: String,
        collectionID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping () -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/expansions"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseVoid {
            (response: RestResponse) in
            switch response.result {
            case .success: success()
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Get tokenization dictionary status.

     Returns the current status of the tokenization dictionary for the specified collection.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getTokenizationDictionaryStatus(
        environmentID: String,
        collectionID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TokenDictStatusResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/word_lists/tokenization_dictionary"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TokenDictStatusResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Create tokenization dictionary.

     Upload a custom tokenization dictionary to use with the specified collection.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter tokenizationRules: An array of tokenization rules. Each rule contains, the original `text` string,
       component `tokens`, any alternate character set `readings`, and which `part_of_speech` the text is from.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func createTokenizationDictionary(
        environmentID: String,
        collectionID: String,
        tokenizationRules: [TokenDictRule]? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TokenDictStatusResponse) -> Void)
    {
        // construct body
        let createTokenizationDictionaryRequest = TokenDict(tokenizationRules: tokenizationRules)
        guard let body = try? JSONEncoder().encodeIfPresent(createTokenizationDictionaryRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/word_lists/tokenization_dictionary"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TokenDictStatusResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete tokenization dictionary.

     Delete the tokenization dictionary from the collection.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteTokenizationDictionary(
        environmentID: String,
        collectionID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping () -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/word_lists/tokenization_dictionary"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseVoid {
            (response: RestResponse) in
            switch response.result {
            case .success: success()
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Add a document.

     Add a document to a collection with optional metadata.
       * The **version** query parameter is still required.
       * Returns immediately after the system has accepted the document for processing.
       * The user must provide document content, metadata, or both. If the request is missing both document content and
     metadata, it is rejected.
       * The user can set the **Content-Type** parameter on the **file** part to indicate the media type of the
     document. If the **Content-Type** parameter is missing or is one of the generic media types (for example,
     `application/octet-stream`), then the service attempts to automatically detect the document's media type.
       * The following field names are reserved and will be filtered out if present after normalization: `id`, `score`,
     `highlight`, and any field with the prefix of: `_`, `+`, or `-`
       * Fields with empty name values after normalization are filtered out before indexing.
       * Fields containing the following characters after normalization are filtered out before indexing: `#` and `,`.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter file: The content of the document to ingest. The maximum supported file size is 50 megabytes. Files
       larger than 50 megabytes is rejected.
     - parameter metadata: If you're using the Data Crawler to upload your documents, you can test a document against
       the type of metadata that the Data Crawler might send. The maximum supported metadata file size is 1 MB. Metadata
       parts larger than 1 MB are rejected.
       Example:  ``` {
         \"Creator\": \"Johnny Appleseed\",
         \"Subject\": \"Apples\"
       } ```.
     - parameter fileContentType: The content type of file.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func addDocument(
        environmentID: String,
        collectionID: String,
        file: URL? = nil,
        metadata: String? = nil,
        fileContentType: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DocumentAccepted) -> Void)
    {
        // construct body
        let multipartFormData = MultipartFormData()
        if let file = file {
            do {
                try multipartFormData.append(file: file, withName: "file")
            } catch {
                failure?(error)
                return
            }
        }
        if let metadata = metadata {
            if let metadataData = metadata.data(using: .utf8) {
                multipartFormData.append(metadataData, withName: "metadata")
            }
        }
        guard let body = try? multipartFormData.toData() else {
            failure?(RestError.encodingError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = multipartFormData.contentType

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/documents"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<DocumentAccepted>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Get document details.

     Fetch status details about a submitted document. **Note:** this operation does not return the document itself.
     Instead, it returns only the document's processing status and any notices (warnings or errors) that were generated
     when the document was ingested. Use the query API to retrieve the actual document content.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter documentID: The ID of the document.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getDocumentStatus(
        environmentID: String,
        collectionID: String,
        documentID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DocumentStatus) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/documents/\(documentID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<DocumentStatus>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Update a document.

     Replace an existing document. Starts ingesting a document with optional metadata.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter documentID: The ID of the document.
     - parameter file: The content of the document to ingest. The maximum supported file size is 50 megabytes. Files
       larger than 50 megabytes is rejected.
     - parameter metadata: If you're using the Data Crawler to upload your documents, you can test a document against
       the type of metadata that the Data Crawler might send. The maximum supported metadata file size is 1 MB. Metadata
       parts larger than 1 MB are rejected.
       Example:  ``` {
         \"Creator\": \"Johnny Appleseed\",
         \"Subject\": \"Apples\"
       } ```.
     - parameter fileContentType: The content type of file.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func updateDocument(
        environmentID: String,
        collectionID: String,
        documentID: String,
        file: URL? = nil,
        metadata: String? = nil,
        fileContentType: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DocumentAccepted) -> Void)
    {
        // construct body
        let multipartFormData = MultipartFormData()
        if let file = file {
            do {
                try multipartFormData.append(file: file, withName: "file")
            } catch {
                failure?(error)
                return
            }
        }
        if let metadata = metadata {
            if let metadataData = metadata.data(using: .utf8) {
                multipartFormData.append(metadataData, withName: "metadata")
            }
        }
        guard let body = try? multipartFormData.toData() else {
            failure?(RestError.encodingError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = multipartFormData.contentType

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/documents/\(documentID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<DocumentAccepted>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete a document.

     If the given document ID is invalid, or if the document is not found, then the a success response is returned (HTTP
     status code `200`) with the status set to 'deleted'.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter documentID: The ID of the document.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteDocument(
        environmentID: String,
        collectionID: String,
        documentID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DeleteDocumentResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/documents/\(documentID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<DeleteDocumentResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Long collection queries.

     Complex queries might be too long for a standard method query. By using this method, you can construct longer
     queries. However, these queries may take longer to complete than the standard method. For details, see the
     [Discovery service documentation](https://console.bluemix.net/docs/services/discovery/using.html).

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter filter: A cacheable query that limits the documents returned to exclude any documents that don't
       mention the query content. Filter searches are better for metadata type searches and when you are trying to get a
       sense of concepts in the data set.
     - parameter query: A query search returns all documents in your data set with full enrichments and full text, but
       with the most relevant documents listed first. Use a query search when you want to find the most relevant search
       results. You cannot use **natural_language_query** and **query** at the same time.
     - parameter naturalLanguageQuery: A natural language query that returns relevant documents by utilizing training
       data and natural language understanding. You cannot use **natural_language_query** and **query** at the same
       time.
     - parameter passages: A passages query that returns the most relevant passages from the results.
     - parameter aggregation: An aggregation search uses combinations of filters and query search to return an exact
       answer. Aggregations are useful for building applications, because you can use them to build lists, tables, and
       time series. For a full list of possible aggregrations, see the Query reference.
     - parameter count: Number of results to return.
     - parameter returnFields: A comma separated list of the portion of the document hierarchy to return.
     - parameter offset: The number of query results to skip at the beginning. For example, if the total number of
       results that are returned is 10, and the offset is 8, it returns the last two results.
     - parameter sort: A comma separated list of fields in the document to sort on. You can optionally specify a sort
       direction by prefixing the field with `-` for descending or `+` for ascending. Ascending is the default sort
       direction if no prefix is specified.
     - parameter highlight: When true a highlight field is returned for each result which contains the fields that
       match the query with `<em></em>` tags around the matching query terms. Defaults to false.
     - parameter passagesFields: A comma-separated list of fields that passages are drawn from. If this parameter not
       specified, then all top-level fields are included.
     - parameter passagesCount: The maximum number of passages to return. The search returns fewer passages if the
       requested total is not found. The default is `10`. The maximum is `100`.
     - parameter passagesCharacters: The approximate number of characters that any one passage will have. The default
       is `400`. The minimum is `50`. The maximum is `2000`.
     - parameter deduplicate: When `true` and used with a Watson Discovery News collection, duplicate results (based
       on the contents of the **title** field) are removed. Duplicate comparison is limited to the current query only;
       **offset** is not considered. This parameter is currently Beta functionality.
     - parameter deduplicateField: When specified, duplicate results based on the field specified are removed from the
       returned results. Duplicate comparison is limited to the current query only, **offset** is not considered. This
       parameter is currently Beta functionality.
     - parameter similar: When `true`, results are returned based on their similarity to the document IDs specified in
       the **similar.document_ids** parameter.
     - parameter similarDocumentIds: A comma-separated list of document IDs that will be used to find similar
       documents.
       **Note:** If the **natural_language_query** parameter is also specified, it will be used to expand the scope of
       the document similarity search to include the natural language query. Other query parameters, such as **filter**
       and **query** are subsequently applied and reduce the query scope.
     - parameter similarFields: A comma-separated list of field names that will be used as a basis for comparison to
       identify similar documents. If not specified, the entire document is used for comparison.
     - parameter bias: Field which the returned results will be biased against. The specified field must be either a
       **date** or **number** format. When a **date** type field is specified returned results are biased towards field
       values closer to the current date. When a **number** type field is specified, returned results are biased towards
       higher field values. This parameter cannot be used in the same query as the **sort** parameter.
     - parameter loggingOptOut: If `true`, queries are not stored in the Discovery **Logs** endpoint.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func query(
        environmentID: String,
        collectionID: String,
        filter: String? = nil,
        query: String? = nil,
        naturalLanguageQuery: String? = nil,
        passages: Bool? = nil,
        aggregation: String? = nil,
        count: Int? = nil,
        returnFields: [String]? = nil,
        offset: Int? = nil,
        sort: [String]? = nil,
        highlight: Bool? = nil,
        passagesFields: [String]? = nil,
        passagesCount: Int? = nil,
        passagesCharacters: Int? = nil,
        deduplicate: Bool? = nil,
        deduplicateField: String? = nil,
        similar: Bool? = nil,
        similarDocumentIds: [String]? = nil,
        similarFields: [String]? = nil,
        bias: String? = nil,
        loggingOptOut: Bool? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (QueryResponse) -> Void)
    {
        // construct body
        let returnFieldsJoined = returnFields?.joined(separator: ",")
        let sortJoined = sort?.joined(separator: ",")
        let passagesFieldsJoined = passagesFields?.joined(separator: ",")
        let similarDocumentIdsJoined = similarDocumentIds?.joined(separator: ",")
        let similarFieldsJoined = similarFields?.joined(separator: ",")
        let queryLong = QueryLarge(
            filter: filter,
            query: query,
            naturalLanguageQuery: naturalLanguageQuery,
            passages: passages,
            aggregation: aggregation,
            count: count,
            returnFields: returnFieldsJoined,
            offset: offset,
            sort: sortJoined,
            highlight: highlight,
            passagesFields: passagesFieldsJoined,
            passagesCount: passagesCount,
            passagesCharacters: passagesCharacters,
            deduplicate: deduplicate,
            deduplicateField: deduplicateField,
            similar: similar,
            similarDocumentIds: similarDocumentIdsJoined,
            similarFields: similarFieldsJoined,
            bias: bias)
        guard let body = try? JSONEncoder().encode(queryLong) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"
        if let loggingOptOut = loggingOptOut {
            headerParameters["X-Watson-Logging-Opt-Out"] = "\(loggingOptOut)"
        }

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/query"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<QueryResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Query system notices.

     Queries for notices (errors or warnings) that might have been generated by the system. Notices are generated when
     ingesting documents and performing relevance training. See the [Discovery service
     documentation](https://console.bluemix.net/docs/services/discovery/using.html) for more details on the query
     language.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter filter: A cacheable query that excludes documents that don't mention the query content. Filter
       searches are better for metadata-type searches and for assessing the concepts in the data set.
     - parameter query: A query search returns all documents in your data set with full enrichments and full text, but
       with the most relevant documents listed first. Use a query search when you want to find the most relevant search
       results. You cannot use **natural_language_query** and **query** at the same time.
     - parameter naturalLanguageQuery: A natural language query that returns relevant documents by utilizing training
       data and natural language understanding. You cannot use **natural_language_query** and **query** at the same
       time.
     - parameter passages: A passages query that returns the most relevant passages from the results.
     - parameter aggregation: An aggregation search that returns an exact answer by combining query search with
       filters. Useful for applications to build lists, tables, and time series. For a full list of possible
       aggregations, see the Query reference.
     - parameter count: Number of results to return.
     - parameter returnFields: A comma-separated list of the portion of the document hierarchy to return.
     - parameter offset: The number of query results to skip at the beginning. For example, if the total number of
       results that are returned is 10 and the offset is 8, it returns the last two results.
     - parameter sort: A comma-separated list of fields in the document to sort on. You can optionally specify a sort
       direction by prefixing the field with `-` for descending or `+` for ascending. Ascending is the default sort
       direction if no prefix is specified.
     - parameter highlight: When true, a highlight field is returned for each result which contains the fields which
       match the query with `<em></em>` tags around the matching query terms.
     - parameter passagesFields: A comma-separated list of fields that passages are drawn from. If this parameter not
       specified, then all top-level fields are included.
     - parameter passagesCount: The maximum number of passages to return. The search returns fewer passages if the
       requested total is not found.
     - parameter passagesCharacters: The approximate number of characters that any one passage will have.
     - parameter deduplicateField: When specified, duplicate results based on the field specified are removed from the
       returned results. Duplicate comparison is limited to the current query only, **offset** is not considered. This
       parameter is currently Beta functionality.
     - parameter similar: When `true`, results are returned based on their similarity to the document IDs specified in
       the **similar.document_ids** parameter.
     - parameter similarDocumentIds: A comma-separated list of document IDs to find similar documents.
       **Tip:** Include the **natural_language_query** parameter to expand the scope of the document similarity search
       with the natural language query. Other query parameters, such as **filter** and **query**, are subsequently
       applied and reduce the scope.
     - parameter similarFields: A comma-separated list of field names that are used as a basis for comparison to
       identify similar documents. If not specified, the entire document is used for comparison.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func queryNotices(
        environmentID: String,
        collectionID: String,
        filter: String? = nil,
        query: String? = nil,
        naturalLanguageQuery: String? = nil,
        passages: Bool? = nil,
        aggregation: String? = nil,
        count: Int? = nil,
        returnFields: [String]? = nil,
        offset: Int? = nil,
        sort: [String]? = nil,
        highlight: Bool? = nil,
        passagesFields: [String]? = nil,
        passagesCount: Int? = nil,
        passagesCharacters: Int? = nil,
        deduplicateField: String? = nil,
        similar: Bool? = nil,
        similarDocumentIds: [String]? = nil,
        similarFields: [String]? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (QueryNoticesResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let filter = filter {
            let queryParameter = URLQueryItem(name: "filter", value: filter)
            queryParameters.append(queryParameter)
        }
        if let query = query {
            let queryParameter = URLQueryItem(name: "query", value: query)
            queryParameters.append(queryParameter)
        }
        if let naturalLanguageQuery = naturalLanguageQuery {
            let queryParameter = URLQueryItem(name: "natural_language_query", value: naturalLanguageQuery)
            queryParameters.append(queryParameter)
        }
        if let passages = passages {
            let queryParameter = URLQueryItem(name: "passages", value: "\(passages)")
            queryParameters.append(queryParameter)
        }
        if let aggregation = aggregation {
            let queryParameter = URLQueryItem(name: "aggregation", value: aggregation)
            queryParameters.append(queryParameter)
        }
        if let count = count {
            let queryParameter = URLQueryItem(name: "count", value: "\(count)")
            queryParameters.append(queryParameter)
        }
        if let returnFields = returnFields {
            let queryParameter = URLQueryItem(name: "return", value: returnFields.joined(separator: ","))
            queryParameters.append(queryParameter)
        }
        if let offset = offset {
            let queryParameter = URLQueryItem(name: "offset", value: "\(offset)")
            queryParameters.append(queryParameter)
        }
        if let sort = sort {
            let queryParameter = URLQueryItem(name: "sort", value: sort.joined(separator: ","))
            queryParameters.append(queryParameter)
        }
        if let highlight = highlight {
            let queryParameter = URLQueryItem(name: "highlight", value: "\(highlight)")
            queryParameters.append(queryParameter)
        }
        if let passagesFields = passagesFields {
            let queryParameter = URLQueryItem(name: "passages.fields", value: passagesFields.joined(separator: ","))
            queryParameters.append(queryParameter)
        }
        if let passagesCount = passagesCount {
            let queryParameter = URLQueryItem(name: "passages.count", value: "\(passagesCount)")
            queryParameters.append(queryParameter)
        }
        if let passagesCharacters = passagesCharacters {
            let queryParameter = URLQueryItem(name: "passages.characters", value: "\(passagesCharacters)")
            queryParameters.append(queryParameter)
        }
        if let deduplicateField = deduplicateField {
            let queryParameter = URLQueryItem(name: "deduplicate.field", value: deduplicateField)
            queryParameters.append(queryParameter)
        }
        if let similar = similar {
            let queryParameter = URLQueryItem(name: "similar", value: "\(similar)")
            queryParameters.append(queryParameter)
        }
        if let similarDocumentIds = similarDocumentIds {
            let queryParameter = URLQueryItem(name: "similar.document_ids", value: similarDocumentIds.joined(separator: ","))
            queryParameters.append(queryParameter)
        }
        if let similarFields = similarFields {
            let queryParameter = URLQueryItem(name: "similar.fields", value: similarFields.joined(separator: ","))
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/notices"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<QueryNoticesResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Long environment queries.

     Complex queries might be too long for a standard method query. By using this method, you can construct longer
     queries. However, these queries may take longer to complete than the standard method. For details, see the
     [Discovery service documentation](https://console.bluemix.net/docs/services/discovery/using.html).

     - parameter environmentID: The ID of the environment.
     - parameter collectionIds: A comma-separated list of collection IDs to be queried against.
     - parameter filter: A cacheable query that limits the documents returned to exclude any documents that don't
       mention the query content. Filter searches are better for metadata type searches and when you are trying to get a
       sense of concepts in the data set.
     - parameter query: A query search returns all documents in your data set with full enrichments and full text, but
       with the most relevant documents listed first. Use a query search when you want to find the most relevant search
       results. You cannot use **natural_language_query** and **query** at the same time.
     - parameter naturalLanguageQuery: A natural language query that returns relevant documents by utilizing training
       data and natural language understanding. You cannot use **natural_language_query** and **query** at the same
       time.
     - parameter aggregation: An aggregation search uses combinations of filters and query search to return an exact
       answer. Aggregations are useful for building applications, because you can use them to build lists, tables, and
       time series. For a full list of possible aggregrations, see the Query reference.
     - parameter count: Number of results to return.
     - parameter returnFields: A comma separated list of the portion of the document hierarchy to return.
     - parameter offset: The number of query results to skip at the beginning. For example, if the total number of
       results that are returned is 10, and the offset is 8, it returns the last two results.
     - parameter sort: A comma separated list of fields in the document to sort on. You can optionally specify a sort
       direction by prefixing the field with `-` for descending or `+` for ascending. Ascending is the default sort
       direction if no prefix is specified.
     - parameter highlight: When true a highlight field is returned for each result which contains the fields that
       match the query with `<em></em>` tags around the matching query terms. Defaults to false.
     - parameter deduplicate: When `true` and used with a Watson Discovery News collection, duplicate results (based
       on the contents of the **title** field) are removed. Duplicate comparison is limited to the current query only;
       **offset** is not considered. This parameter is currently Beta functionality.
     - parameter deduplicateField: When specified, duplicate results based on the field specified are removed from the
       returned results. Duplicate comparison is limited to the current query only, **offset** is not considered. This
       parameter is currently Beta functionality.
     - parameter similar: When `true`, results are returned based on their similarity to the document IDs specified in
       the **similar.document_ids** parameter.
     - parameter similarDocumentIds: A comma-separated list of document IDs that will be used to find similar
       documents.
       **Note:** If the **natural_language_query** parameter is also specified, it will be used to expand the scope of
       the document similarity search to include the natural language query. Other query parameters, such as **filter**
       and **query** are subsequently applied and reduce the query scope.
     - parameter similarFields: A comma-separated list of field names that will be used as a basis for comparison to
       identify similar documents. If not specified, the entire document is used for comparison.
     - parameter passages: A passages query that returns the most relevant passages from the results.
     - parameter passagesFields: A comma-separated list of fields that passages are drawn from. If this parameter not
       specified, then all top-level fields are included.
     - parameter passagesCount: The maximum number of passages to return. The search returns fewer passages if the
       requested total is not found. The default is `10`. The maximum is `100`.
     - parameter passagesCharacters: The approximate number of characters that any one passage will have. The default
       is `400`. The minimum is `50`. The maximum is `2000`.
     - parameter bias: Field which the returned results will be biased against. The specified field must be either a
       **date** or **number** format. When a **date** type field is specified returned results are biased towards field
       values closer to the current date. When a **number** type field is specified, returned results are biased towards
       higher field values. This parameter cannot be used in the same query as the **sort** parameter.
     - parameter loggingOptOut: If `true`, queries are not stored in the Discovery **Logs** endpoint.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func federatedQuery(
        environmentID: String,
        collectionIds: [String],
        filter: String? = nil,
        query: String? = nil,
        naturalLanguageQuery: String? = nil,
        aggregation: String? = nil,
        count: Int? = nil,
        returnFields: [String]? = nil,
        offset: Int? = nil,
        sort: [String]? = nil,
        highlight: Bool? = nil,
        deduplicate: Bool? = nil,
        deduplicateField: String? = nil,
        similar: Bool? = nil,
        similarDocumentIds: [String]? = nil,
        similarFields: [String]? = nil,
        passages: Bool? = nil,
        passagesFields: [String]? = nil,
        passagesCount: Int? = nil,
        passagesCharacters: Int? = nil,
        bias: String? = nil,
        loggingOptOut: Bool? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (QueryResponse) -> Void)
    {
        // construct body
        let returnFieldsJoined = returnFields?.joined(separator: ",")
        let sortJoined = sort?.joined(separator: ",")
        let passagesFieldsJoined = passagesFields?.joined(separator: ",")
        let collectionIdsJoined = collectionIds.joined(separator: ",")
        let similarDocumentIdsJoined = similarDocumentIds?.joined(separator: ",")
        let similarFieldsJoined = similarFields?.joined(separator: ",")
        let queryLong = QueryLarge(
            filter: filter,
            query: query,
            naturalLanguageQuery: naturalLanguageQuery,
            passages: passages,
            aggregation: aggregation,
            count: count,
            returnFields: returnFieldsJoined,
            offset: offset,
            sort: sortJoined,
            highlight: highlight,
            passagesFields: passagesFieldsJoined,
            passagesCount: passagesCount,
            passagesCharacters: passagesCharacters,
            deduplicate: deduplicate,
            deduplicateField: deduplicateField,
            collectionIds: collectionIdsJoined,
            similar: similar,
            similarDocumentIds: similarDocumentIdsJoined,
            similarFields: similarFieldsJoined,
            bias: bias)
        guard let body = try? JSONEncoder().encode(queryLong) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"
        if let loggingOptOut = loggingOptOut {
            headerParameters["X-Watson-Logging-Opt-Out"] = "\(loggingOptOut)"
        }

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/query"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<QueryResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Query multiple collection system notices.

     Queries for notices (errors or warnings) that might have been generated by the system. Notices are generated when
     ingesting documents and performing relevance training. See the [Discovery service
     documentation](https://console.bluemix.net/docs/services/discovery/using.html) for more details on the query
     language.

     - parameter environmentID: The ID of the environment.
     - parameter collectionIds: A comma-separated list of collection IDs to be queried against.
     - parameter filter: A cacheable query that excludes documents that don't mention the query content. Filter
       searches are better for metadata-type searches and for assessing the concepts in the data set.
     - parameter query: A query search returns all documents in your data set with full enrichments and full text, but
       with the most relevant documents listed first. Use a query search when you want to find the most relevant search
       results. You cannot use **natural_language_query** and **query** at the same time.
     - parameter naturalLanguageQuery: A natural language query that returns relevant documents by utilizing training
       data and natural language understanding. You cannot use **natural_language_query** and **query** at the same
       time.
     - parameter aggregation: An aggregation search that returns an exact answer by combining query search with
       filters. Useful for applications to build lists, tables, and time series. For a full list of possible
       aggregations, see the Query reference.
     - parameter count: Number of results to return.
     - parameter returnFields: A comma-separated list of the portion of the document hierarchy to return.
     - parameter offset: The number of query results to skip at the beginning. For example, if the total number of
       results that are returned is 10 and the offset is 8, it returns the last two results.
     - parameter sort: A comma-separated list of fields in the document to sort on. You can optionally specify a sort
       direction by prefixing the field with `-` for descending or `+` for ascending. Ascending is the default sort
       direction if no prefix is specified.
     - parameter highlight: When true, a highlight field is returned for each result which contains the fields which
       match the query with `<em></em>` tags around the matching query terms.
     - parameter deduplicateField: When specified, duplicate results based on the field specified are removed from the
       returned results. Duplicate comparison is limited to the current query only, **offset** is not considered. This
       parameter is currently Beta functionality.
     - parameter similar: When `true`, results are returned based on their similarity to the document IDs specified in
       the **similar.document_ids** parameter.
     - parameter similarDocumentIds: A comma-separated list of document IDs to find similar documents.
       **Tip:** Include the **natural_language_query** parameter to expand the scope of the document similarity search
       with the natural language query. Other query parameters, such as **filter** and **query**, are subsequently
       applied and reduce the scope.
     - parameter similarFields: A comma-separated list of field names that are used as a basis for comparison to
       identify similar documents. If not specified, the entire document is used for comparison.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func federatedQueryNotices(
        environmentID: String,
        collectionIds: [String],
        filter: String? = nil,
        query: String? = nil,
        naturalLanguageQuery: String? = nil,
        aggregation: String? = nil,
        count: Int? = nil,
        returnFields: [String]? = nil,
        offset: Int? = nil,
        sort: [String]? = nil,
        highlight: Bool? = nil,
        deduplicateField: String? = nil,
        similar: Bool? = nil,
        similarDocumentIds: [String]? = nil,
        similarFields: [String]? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (QueryNoticesResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        queryParameters.append(URLQueryItem(name: "collection_ids", value: collectionIds.joined(separator: ",")))
        if let filter = filter {
            let queryParameter = URLQueryItem(name: "filter", value: filter)
            queryParameters.append(queryParameter)
        }
        if let query = query {
            let queryParameter = URLQueryItem(name: "query", value: query)
            queryParameters.append(queryParameter)
        }
        if let naturalLanguageQuery = naturalLanguageQuery {
            let queryParameter = URLQueryItem(name: "natural_language_query", value: naturalLanguageQuery)
            queryParameters.append(queryParameter)
        }
        if let aggregation = aggregation {
            let queryParameter = URLQueryItem(name: "aggregation", value: aggregation)
            queryParameters.append(queryParameter)
        }
        if let count = count {
            let queryParameter = URLQueryItem(name: "count", value: "\(count)")
            queryParameters.append(queryParameter)
        }
        if let returnFields = returnFields {
            let queryParameter = URLQueryItem(name: "return", value: returnFields.joined(separator: ","))
            queryParameters.append(queryParameter)
        }
        if let offset = offset {
            let queryParameter = URLQueryItem(name: "offset", value: "\(offset)")
            queryParameters.append(queryParameter)
        }
        if let sort = sort {
            let queryParameter = URLQueryItem(name: "sort", value: sort.joined(separator: ","))
            queryParameters.append(queryParameter)
        }
        if let highlight = highlight {
            let queryParameter = URLQueryItem(name: "highlight", value: "\(highlight)")
            queryParameters.append(queryParameter)
        }
        if let deduplicateField = deduplicateField {
            let queryParameter = URLQueryItem(name: "deduplicate.field", value: deduplicateField)
            queryParameters.append(queryParameter)
        }
        if let similar = similar {
            let queryParameter = URLQueryItem(name: "similar", value: "\(similar)")
            queryParameters.append(queryParameter)
        }
        if let similarDocumentIds = similarDocumentIds {
            let queryParameter = URLQueryItem(name: "similar.document_ids", value: similarDocumentIds.joined(separator: ","))
            queryParameters.append(queryParameter)
        }
        if let similarFields = similarFields {
            let queryParameter = URLQueryItem(name: "similar.fields", value: similarFields.joined(separator: ","))
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let path = "/v1/environments/\(environmentID)/notices"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<QueryNoticesResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Knowledge Graph entity query.

     See the [Knowledge Graph documentation](https://console.bluemix.net/docs/services/discovery/building-kg.html) for
     more details.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter entityQuery: An object specifying the entities to query, which functions to perform, and any
       additional constraints.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func queryEntities(
        environmentID: String,
        collectionID: String,
        entityQuery: QueryEntities,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (QueryEntitiesResponse) -> Void)
    {
        // construct body
        guard let body = try? JSONEncoder().encode(entityQuery) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/query_entities"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<QueryEntitiesResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Knowledge Graph relationship query.

     See the [Knowledge Graph documentation](https://console.bluemix.net/docs/services/discovery/building-kg.html) for
     more details.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter relationshipQuery: An object that describes the relationships to be queried and any query constraints
       (such as filters).
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func queryRelations(
        environmentID: String,
        collectionID: String,
        relationshipQuery: QueryRelations,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (QueryRelationsResponse) -> Void)
    {
        // construct body
        guard let body = try? JSONEncoder().encode(relationshipQuery) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/query_relations"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<QueryRelationsResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     List training data.

     Lists the training data for the specified collection.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func listTrainingData(
        environmentID: String,
        collectionID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TrainingDataSet) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TrainingDataSet>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Add query to training data.

     Adds a query to the training data for this collection. The query can contain a filter and natural language query.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter naturalLanguageQuery:
     - parameter filter:
     - parameter examples:
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func addTrainingData(
        environmentID: String,
        collectionID: String,
        naturalLanguageQuery: String? = nil,
        filter: String? = nil,
        examples: [TrainingExample]? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TrainingQuery) -> Void)
    {
        // construct body
        let addTrainingDataRequest = NewTrainingQuery(naturalLanguageQuery: naturalLanguageQuery, filter: filter, examples: examples)
        guard let body = try? JSONEncoder().encode(addTrainingDataRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TrainingQuery>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete all training data.

     Deletes all training data from a collection.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteAllTrainingData(
        environmentID: String,
        collectionID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping () -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseVoid {
            (response: RestResponse) in
            switch response.result {
            case .success: success()
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Get details about a query.

     Gets details for a specific training data query, including the query string and all examples.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter queryID: The ID of the query used for training.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getTrainingData(
        environmentID: String,
        collectionID: String,
        queryID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TrainingQuery) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data/\(queryID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TrainingQuery>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete a training data query.

     Removes the training data query and all associated examples from the training data set.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter queryID: The ID of the query used for training.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteTrainingData(
        environmentID: String,
        collectionID: String,
        queryID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping () -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data/\(queryID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseVoid {
            (response: RestResponse) in
            switch response.result {
            case .success: success()
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     List examples for a training data query.

     List all examples for this training data query.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter queryID: The ID of the query used for training.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func listTrainingExamples(
        environmentID: String,
        collectionID: String,
        queryID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TrainingExampleList) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data/\(queryID)/examples"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TrainingExampleList>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Add example to training data query.

     Adds a example to this training data query.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter queryID: The ID of the query used for training.
     - parameter documentID:
     - parameter crossReference:
     - parameter relevance:
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func createTrainingExample(
        environmentID: String,
        collectionID: String,
        queryID: String,
        documentID: String? = nil,
        crossReference: String? = nil,
        relevance: Int? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TrainingExample) -> Void)
    {
        // construct body
        let createTrainingExampleRequest = TrainingExample(documentID: documentID, crossReference: crossReference, relevance: relevance)
        guard let body = try? JSONEncoder().encode(createTrainingExampleRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data/\(queryID)/examples"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TrainingExample>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete example for training data query.

     Deletes the example document with the given ID from the training data query.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter queryID: The ID of the query used for training.
     - parameter exampleID: The ID of the document as it is indexed.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteTrainingExample(
        environmentID: String,
        collectionID: String,
        queryID: String,
        exampleID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping () -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data/\(queryID)/examples/\(exampleID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseVoid {
            (response: RestResponse) in
            switch response.result {
            case .success: success()
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Change label or cross reference for example.

     Changes the label or cross reference query for this training data example.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter queryID: The ID of the query used for training.
     - parameter exampleID: The ID of the document as it is indexed.
     - parameter crossReference:
     - parameter relevance:
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func updateTrainingExample(
        environmentID: String,
        collectionID: String,
        queryID: String,
        exampleID: String,
        crossReference: String? = nil,
        relevance: Int? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TrainingExample) -> Void)
    {
        // construct body
        let updateTrainingExampleRequest = TrainingExamplePatch(crossReference: crossReference, relevance: relevance)
        guard let body = try? JSONEncoder().encode(updateTrainingExampleRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data/\(queryID)/examples/\(exampleID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "PUT",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TrainingExample>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Get details for training data example.

     Gets the details for this training example.

     - parameter environmentID: The ID of the environment.
     - parameter collectionID: The ID of the collection.
     - parameter queryID: The ID of the query used for training.
     - parameter exampleID: The ID of the document as it is indexed.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getTrainingExample(
        environmentID: String,
        collectionID: String,
        queryID: String,
        exampleID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (TrainingExample) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/collections/\(collectionID)/training_data/\(queryID)/examples/\(exampleID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<TrainingExample>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete labeled data.

     Deletes all data associated with a specified customer ID. The method has no effect if no data is associated with
     the customer ID.
     You associate a customer ID with data by passing the **X-Watson-Metadata** header with a request that passes data.
     For more information about personal data and customer IDs, see [Information
     security](https://console.bluemix.net/docs/services/discovery/information-security.html).

     - parameter customerID: The customer ID for which all data is to be deleted.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteUserData(
        customerID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping () -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        queryParameters.append(URLQueryItem(name: "customer_id", value: customerID))

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + "/v1/user_data",
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseVoid {
            (response: RestResponse) in
            switch response.result {
            case .success: success()
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Create event.

     The **Events** API can be used to create log entries that are associated with specific queries. For example, you
     can record which documents in the results set were \"clicked\" by a user and when that click occured.

     - parameter type: The event type to be created.
     - parameter data: Data object used to create a query event.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func createEvent(
        type: String,
        data: EventData,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (CreateEventResponse) -> Void)
    {
        // construct body
        let createEventRequest = CreateEventObject(type: type, data: data)
        guard let body = try? JSONEncoder().encode(createEventRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + "/v1/events",
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<CreateEventResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Search the query and event log.

     Searches the query and event log to find query sessions that match the specified criteria. Searching the **logs**
     endpoint uses the standard Discovery query syntax for the parameters that are supported.

     - parameter filter: A cacheable query that excludes documents that don't mention the query content. Filter
       searches are better for metadata-type searches and for assessing the concepts in the data set.
     - parameter query: A query search returns all documents in your data set with full enrichments and full text, but
       with the most relevant documents listed first. Use a query search when you want to find the most relevant search
       results. You cannot use **natural_language_query** and **query** at the same time.
     - parameter count: Number of results to return.
     - parameter offset: The number of query results to skip at the beginning. For example, if the total number of
       results that are returned is 10 and the offset is 8, it returns the last two results.
     - parameter sort: A comma-separated list of fields in the document to sort on. You can optionally specify a sort
       direction by prefixing the field with `-` for descending or `+` for ascending. Ascending is the default sort
       direction if no prefix is specified.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func queryLog(
        filter: String? = nil,
        query: String? = nil,
        count: Int? = nil,
        offset: Int? = nil,
        sort: [String]? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (LogQueryResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let filter = filter {
            let queryParameter = URLQueryItem(name: "filter", value: filter)
            queryParameters.append(queryParameter)
        }
        if let query = query {
            let queryParameter = URLQueryItem(name: "query", value: query)
            queryParameters.append(queryParameter)
        }
        if let count = count {
            let queryParameter = URLQueryItem(name: "count", value: "\(count)")
            queryParameters.append(queryParameter)
        }
        if let offset = offset {
            let queryParameter = URLQueryItem(name: "offset", value: "\(offset)")
            queryParameters.append(queryParameter)
        }
        if let sort = sort {
            let queryParameter = URLQueryItem(name: "sort", value: sort.joined(separator: ","))
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + "/v1/logs",
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<LogQueryResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Number of queries over time.

     Total number of queries using the **natural_language_query** parameter over a specific time window.

     - parameter startTime: Metric is computed from data recorded after this timestamp; must be in
       `YYYY-MM-DDThh:mm:ssZ` format.
     - parameter endTime: Metric is computed from data recorded before this timestamp; must be in
       `YYYY-MM-DDThh:mm:ssZ` format.
     - parameter resultType: The type of result to consider when calculating the metric.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getMetricsQuery(
        startTime: String? = nil,
        endTime: String? = nil,
        resultType: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (MetricResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let startTime = startTime {
            let queryParameter = URLQueryItem(name: "start_time", value: startTime)
            queryParameters.append(queryParameter)
        }
        if let endTime = endTime {
            let queryParameter = URLQueryItem(name: "end_time", value: endTime)
            queryParameters.append(queryParameter)
        }
        if let resultType = resultType {
            let queryParameter = URLQueryItem(name: "result_type", value: resultType)
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + "/v1/metrics/number_of_queries",
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<MetricResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Number of queries with an event over time.

     Total number of queries using the **natural_language_query** parameter that have a corresponding \"click\" event
     over a specified time window. This metric requires having integrated event tracking in your application using the
     **Events** API.

     - parameter startTime: Metric is computed from data recorded after this timestamp; must be in
       `YYYY-MM-DDThh:mm:ssZ` format.
     - parameter endTime: Metric is computed from data recorded before this timestamp; must be in
       `YYYY-MM-DDThh:mm:ssZ` format.
     - parameter resultType: The type of result to consider when calculating the metric.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getMetricsQueryEvent(
        startTime: String? = nil,
        endTime: String? = nil,
        resultType: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (MetricResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let startTime = startTime {
            let queryParameter = URLQueryItem(name: "start_time", value: startTime)
            queryParameters.append(queryParameter)
        }
        if let endTime = endTime {
            let queryParameter = URLQueryItem(name: "end_time", value: endTime)
            queryParameters.append(queryParameter)
        }
        if let resultType = resultType {
            let queryParameter = URLQueryItem(name: "result_type", value: resultType)
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + "/v1/metrics/number_of_queries_with_event",
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<MetricResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Number of queries with no search results over time.

     Total number of queries using the **natural_language_query** parameter that have no results returned over a
     specified time window.

     - parameter startTime: Metric is computed from data recorded after this timestamp; must be in
       `YYYY-MM-DDThh:mm:ssZ` format.
     - parameter endTime: Metric is computed from data recorded before this timestamp; must be in
       `YYYY-MM-DDThh:mm:ssZ` format.
     - parameter resultType: The type of result to consider when calculating the metric.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getMetricsQueryNoResults(
        startTime: String? = nil,
        endTime: String? = nil,
        resultType: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (MetricResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let startTime = startTime {
            let queryParameter = URLQueryItem(name: "start_time", value: startTime)
            queryParameters.append(queryParameter)
        }
        if let endTime = endTime {
            let queryParameter = URLQueryItem(name: "end_time", value: endTime)
            queryParameters.append(queryParameter)
        }
        if let resultType = resultType {
            let queryParameter = URLQueryItem(name: "result_type", value: resultType)
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + "/v1/metrics/number_of_queries_with_no_search_results",
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<MetricResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Percentage of queries with an associated event.

     The percentage of queries using the **natural_language_query** parameter that have a corresponding \"click\" event
     over a specified time window.  This metric requires having integrated event tracking in your application using the
     **Events** API.

     - parameter startTime: Metric is computed from data recorded after this timestamp; must be in
       `YYYY-MM-DDThh:mm:ssZ` format.
     - parameter endTime: Metric is computed from data recorded before this timestamp; must be in
       `YYYY-MM-DDThh:mm:ssZ` format.
     - parameter resultType: The type of result to consider when calculating the metric.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getMetricsEventRate(
        startTime: String? = nil,
        endTime: String? = nil,
        resultType: String? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (MetricResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let startTime = startTime {
            let queryParameter = URLQueryItem(name: "start_time", value: startTime)
            queryParameters.append(queryParameter)
        }
        if let endTime = endTime {
            let queryParameter = URLQueryItem(name: "end_time", value: endTime)
            queryParameters.append(queryParameter)
        }
        if let resultType = resultType {
            let queryParameter = URLQueryItem(name: "result_type", value: resultType)
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + "/v1/metrics/event_rate",
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<MetricResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Most frequent query tokens with an event.

     The most frequent query tokens parsed from the **natural_language_query** parameter and their corresponding
     \"click\" event rate within the recording period (queries and events are stored for 30 days). A query token is an
     individual word or unigram within the query string.

     - parameter count: Number of results to return.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getMetricsQueryTokenEvent(
        count: Int? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (MetricTokenResponse) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let count = count {
            let queryParameter = URLQueryItem(name: "count", value: "\(count)")
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + "/v1/metrics/top_query_tokens_with_event_rate",
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<MetricTokenResponse>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     List credentials.

     List all the source credentials that have been created for this service instance.
      **Note:**  All credentials are sent over an encrypted connection and encrypted at rest.

     - parameter environmentID: The ID of the environment.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func listCredentials(
        environmentID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (CredentialsList) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/credentials"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<CredentialsList>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Create credentials.

     Creates a set of credentials to connect to a remote source. Created credentials are used in a configuration to
     associate a collection with the remote source.
     **Note:** All credentials are sent over an encrypted connection and encrypted at rest.

     - parameter environmentID: The ID of the environment.
     - parameter sourceType: The source that this credentials object connects to.
       -  `box` indicates the credentials are used to connect an instance of Enterprise Box.
       -  `salesforce` indicates the credentials are used to connect to Salesforce.
       -  `sharepoint` indicates the credentials are used to connect to Microsoft SharePoint Online.
     - parameter credentialDetails: Object containing details of the stored credentials.
       Obtain credentials for your source from the administrator of the source.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func createCredentials(
        environmentID: String,
        sourceType: String? = nil,
        credentialDetails: CredentialDetails? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Credentials) -> Void)
    {
        // construct body
        let createCredentialsRequest = Credentials(sourceType: sourceType, credentialDetails: credentialDetails)
        guard let body = try? JSONEncoder().encode(createCredentialsRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/credentials"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Credentials>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     View Credentials.

     Returns details about the specified credentials.
      **Note:** Secure credential information such as a password or SSH key is never returned and must be obtained from
     the source system.

     - parameter environmentID: The ID of the environment.
     - parameter credentialID: The unique identifier for a set of source credentials.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func getCredentials(
        environmentID: String,
        credentialID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Credentials) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/credentials/\(credentialID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Credentials>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Update credentials.

     Updates an existing set of source credentials.
     **Note:** All credentials are sent over an encrypted connection and encrypted at rest.

     - parameter environmentID: The ID of the environment.
     - parameter credentialID: The unique identifier for a set of source credentials.
     - parameter sourceType: The source that this credentials object connects to.
       -  `box` indicates the credentials are used to connect an instance of Enterprise Box.
       -  `salesforce` indicates the credentials are used to connect to Salesforce.
       -  `sharepoint` indicates the credentials are used to connect to Microsoft SharePoint Online.
     - parameter credentialDetails: Object containing details of the stored credentials.
       Obtain credentials for your source from the administrator of the source.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func updateCredentials(
        environmentID: String,
        credentialID: String,
        sourceType: String? = nil,
        credentialDetails: CredentialDetails? = nil,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Credentials) -> Void)
    {
        // construct body
        let updateCredentialsRequest = Credentials(sourceType: sourceType, credentialDetails: credentialDetails)
        guard let body = try? JSONEncoder().encode(updateCredentialsRequest) else {
            failure?(RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/credentials/\(credentialID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "PUT",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<Credentials>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

    /**
     Delete credentials.

     Deletes a set of stored credentials from your Discovery instance.

     - parameter environmentID: The ID of the environment.
     - parameter credentialID: The unique identifier for a set of source credentials.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the successful result.
     */
    public func deleteCredentials(
        environmentID: String,
        credentialID: String,
        headers: [String: String]? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DeleteCredentials) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))

        // construct REST request
        let path = "/v1/environments/\(environmentID)/credentials/\(credentialID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            failure?(RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject {
            (response: RestResponse<DeleteCredentials>) in
            switch response.result {
            case .success(let retval): success(retval)
            case .failure(let error): failure?(error)
            }
        }
    }

}
