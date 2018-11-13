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

import Foundation

/**
 Analysis features and options.
 */
public struct Features: Encodable {

    /**
     Returns high-level concepts in the content. For example, a research paper about deep learning might return the
     concept, "Artificial Intelligence" although the term is not mentioned.
     Supported languages: English, French, German, Japanese, Korean, Portuguese, Spanish.
     */
    public var concepts: ConceptsOptions?

    /**
     Detects anger, disgust, fear, joy, or sadness that is conveyed in the content or by the context around target
     phrases specified in the targets parameter. You can analyze emotion for detected entities with `entities.emotion`
     and for keywords with `keywords.emotion`.
     Supported languages: English
     */
    public var emotion: EmotionOptions?

    /**
     Identifies people, cities, organizations, and other entities in the content. See [Entity types and
     subtypes](/docs/services/natural-language-understanding/entity-types.html).
     Supported languages: English, French, German, Italian, Japanese, Korean, Portuguese, Russian, Spanish, Swedish.
     Arabic, Chinese, and Dutch custom models are also supported.
     */
    public var entities: EntitiesOptions?

    /**
     Returns important keywords in the content.
     Supported languages: English, French, German, Italian, Japanese, Korean, Portuguese, Russian, Spanish, Swedish.
     */
    public var keywords: KeywordsOptions?

    /**
     Returns information from the document, including author name, title, RSS/ATOM feeds, prominent page image, and
     publication date. Supports URL and HTML input types only.
     */
    public var metadata: MetadataOptions?

    /**
     Recognizes when two entities are related and identifies the type of relation. For example, an `awardedTo` relation
     might connect the entities "Nobel Prize" and "Albert Einstein". See [Relation
     types](/docs/services/natural-language-understanding/relations.html).
     Supported languages: Arabic, English, German, Japanese, Korean, Spanish. Chinese, Dutch, French, Italian, and
     Portuguese custom models are also supported.
     */
    public var relations: RelationsOptions?

    /**
     Parses sentences into subject, action, and object form.
     Supported languages: English, German, Japanese, Korean, Spanish.
     */
    public var semanticRoles: SemanticRolesOptions?

    /**
     Analyzes the general sentiment of your content or the sentiment toward specific target phrases. You can analyze
     sentiment for detected entities with `entities.sentiment` and for keywords with `keywords.sentiment`.
      Supported languages: Arabic, English, French, German, Italian, Japanese, Korean, Portuguese, Russian, Spanish
     */
    public var sentiment: SentimentOptions?

    /**
     Returns a five-level taxonomy of the content. The top three categories are returned.
     Supported languages: Arabic, English, French, German, Italian, Japanese, Korean, Portuguese, Spanish.
     */
    public var categories: CategoriesOptions?

    // Map each property name to the key that shall be used for encoding/decoding.
    private enum CodingKeys: String, CodingKey {
        case concepts = "concepts"
        case emotion = "emotion"
        case entities = "entities"
        case keywords = "keywords"
        case metadata = "metadata"
        case relations = "relations"
        case semanticRoles = "semantic_roles"
        case sentiment = "sentiment"
        case categories = "categories"
    }

    /**
     Initialize a `Features` with member variables.

     - parameter concepts: Returns high-level concepts in the content. For example, a research paper about deep
       learning might return the concept, "Artificial Intelligence" although the term is not mentioned.
       Supported languages: English, French, German, Japanese, Korean, Portuguese, Spanish.
     - parameter emotion: Detects anger, disgust, fear, joy, or sadness that is conveyed in the content or by the
       context around target phrases specified in the targets parameter. You can analyze emotion for detected entities
       with `entities.emotion` and for keywords with `keywords.emotion`.
       Supported languages: English
     - parameter entities: Identifies people, cities, organizations, and other entities in the content. See [Entity
       types and subtypes](/docs/services/natural-language-understanding/entity-types.html).
       Supported languages: English, French, German, Italian, Japanese, Korean, Portuguese, Russian, Spanish, Swedish.
       Arabic, Chinese, and Dutch custom models are also supported.
     - parameter keywords: Returns important keywords in the content.
       Supported languages: English, French, German, Italian, Japanese, Korean, Portuguese, Russian, Spanish, Swedish.
     - parameter metadata: Returns information from the document, including author name, title, RSS/ATOM feeds,
       prominent page image, and publication date. Supports URL and HTML input types only.
     - parameter relations: Recognizes when two entities are related and identifies the type of relation. For
       example, an `awardedTo` relation might connect the entities "Nobel Prize" and "Albert Einstein". See [Relation
       types](/docs/services/natural-language-understanding/relations.html).
       Supported languages: Arabic, English, German, Japanese, Korean, Spanish. Chinese, Dutch, French, Italian, and
       Portuguese custom models are also supported.
     - parameter semanticRoles: Parses sentences into subject, action, and object form.
       Supported languages: English, German, Japanese, Korean, Spanish.
     - parameter sentiment: Analyzes the general sentiment of your content or the sentiment toward specific target
       phrases. You can analyze sentiment for detected entities with `entities.sentiment` and for keywords with
       `keywords.sentiment`.
        Supported languages: Arabic, English, French, German, Italian, Japanese, Korean, Portuguese, Russian, Spanish
     - parameter categories: Returns a five-level taxonomy of the content. The top three categories are returned.
       Supported languages: Arabic, English, French, German, Italian, Japanese, Korean, Portuguese, Spanish.

     - returns: An initialized `Features`.
    */
    public init(
        concepts: ConceptsOptions? = nil,
        emotion: EmotionOptions? = nil,
        entities: EntitiesOptions? = nil,
        keywords: KeywordsOptions? = nil,
        metadata: MetadataOptions? = nil,
        relations: RelationsOptions? = nil,
        semanticRoles: SemanticRolesOptions? = nil,
        sentiment: SentimentOptions? = nil,
        categories: CategoriesOptions? = nil
    )
    {
        self.concepts = concepts
        self.emotion = emotion
        self.entities = entities
        self.keywords = keywords
        self.metadata = metadata
        self.relations = relations
        self.semanticRoles = semanticRoles
        self.sentiment = sentiment
        self.categories = categories
    }

}
