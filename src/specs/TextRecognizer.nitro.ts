import type { HybridObject } from 'react-native-nitro-modules'
import type { Frame, PreviewViewMethods } from 'react-native-vision-camera'
import type { CameraOutput } from 'react-native-vision-camera'

/**
 * Controls which camera buffer resolution should be used for text scanning.
 */
export type TextRecognizerOutputResolution = 'preview' | 'full'

/**
 * Represents a Point in the current context's coordinate system.
 */
export interface Point {
  /** The X coordinate of the Point. */
  readonly x: number
  /** The Y coordinate of the Point. */
  readonly y: number
}

/**
 * Represents a bounding box in the current context's coordinate system.
 * Coordinates are normalized to the range [0, 1] relative to the frame dimensions,
 * with the origin at the top-left corner.
 */
export interface BoundingBox {
  /** The X coordinate of the top-left corner. */
  readonly x: number
  /** The Y coordinate of the top-left corner. */
  readonly y: number
  /** The width of the bounding box. */
  readonly width: number
  /** The height of the bounding box. */
  readonly height: number
}

/**
 * Represents a single word.
 */
export interface TextWord {
  /** The text content of this word. */
  readonly text: string
  /** The bounding box of this word, relative to the Frame's coordinates. */
  readonly boundingBox: BoundingBox
  /** The corner points of this word. */
  readonly cornerPoints: Point[]
}

/**
 * Represents a single line of text.
 */
export interface TextLine {
  /** The text content of this line. */
  readonly text: string
  /** The bounding box of this line, relative to the Frame's coordinates. */
  readonly boundingBox: BoundingBox
  /** The corner points of this line. */
  readonly cornerPoints: Point[]
  /** The words in this line. */
  readonly words: TextWord[]
}

/**
 * Represents a single detected text block.
 */
export interface TextBlock {
  /** The text content of this block. */
  readonly text: string
  /** The bounding box of this block, relative to the Frame's coordinates. */
  readonly boundingBox: BoundingBox
  /** The corner points of this block. */
  readonly cornerPoints: Point[]
  /** The lines in this block. */
  readonly lines: TextLine[]
}

/**
 * Represents a complete text recognition result from a Frame.
 */
export interface TextRecognizerResult
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  /**
   * The raw text content of the entire recognized text.
   */
  readonly text: string
  /**
   * The blocks of recognized text.
   */
  readonly blocks: TextBlock[]
  /**
   * The bounding box of the complete text recognition result,
   * relative to the input {@linkcode Frame}'s coordinates.
   */
  readonly boundingBox: BoundingBox
  /**
   * The corner points of the complete text recognition result.
   */
  readonly cornerPoints: Point[]
  /**
   * Width of the processed frame in pixels (display/upright orientation).
   * Use together with frameHeight to correctly map normalized bounding boxes
   * to view coordinates accounting for cover-mode cropping.
   */
  readonly frameWidth: number
  /**
   * Height of the processed frame in pixels (display/upright orientation).
   */
  readonly frameHeight: number
}

/**
 * Options for creating a {@linkcode TextRecognizer}.
 */
export interface TextRecognizerOptions {
  /**
   * Specifies the languages to use for text recognition.
   * ML Kit will use these languages to improve recognition accuracy.
   */
  languages?: string[]
}

/**
 * Options for creating a {@linkcode TextRecognizerOutput}.
 */
export interface TextRecognizerOutputOptions {
  /**
   * Specifies the languages to use for text recognition.
   * ML Kit will use these languages to improve recognition accuracy.
   */
  languages?: string[]
  /**
   * Controls which camera buffer resolution should be used.
   *
   * - `'preview'`: Prefer preview-sized buffers for lower latency.
   * - `'full'`: Prefer full/highest available buffers for better detail.
   *
   * @default 'preview'
   */
  outputResolution?: TextRecognizerOutputResolution
  /**
   * Called whenever text has been detected.
   */
  onTextScanned: (results: TextRecognizerResult[]) => void
  /**
   * Called when there was an error detecting text.
   */
  onError: (error: Error) => void
}

/**
 * Represents a Text Recognizer that uses MLKit Text Recognition.
 */
export interface TextRecognizer
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  /**
   * Synchronously detects text in the given {@linkcode Frame}.
   */
  recognizeText(frame: Frame): TextRecognizerResult[]
  /**
   * Asynchronously detects text in the given {@linkcode Frame}.
   */
  recognizeTextAsync(frame: Frame): Promise<TextRecognizerResult[]>
}

/**
 * Factory for creating TextRecognizer instances and CameraOutputs.
 */
export interface TextRecognizerFactory
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  /**
   * Create a new {@linkcode TextRecognizer}.
   */
  createTextRecognizer(options: TextRecognizerOptions): TextRecognizer
  /**
   * Create a new {@linkcode CameraOutput} that can detect text.
   */
  createTextRecognizerOutput(options: TextRecognizerOutputOptions): CameraOutput
}