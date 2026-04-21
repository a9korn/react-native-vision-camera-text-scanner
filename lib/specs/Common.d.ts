/**
 * Represents a Point in the current context's coordinate system.
 */
export interface Point {
    /** The X coordinate of the Point. */
    readonly x: number;
    /** The Y coordinate of the Point. */
    readonly y: number;
}
/**
 * Represents a Rectangle in the current context's coordinate system.
 */
export interface Rect {
    /** The left value (min X) of the Rectangle. */
    readonly left: number;
    /** The right value (max X) of the Rectangle. */
    readonly right: number;
    /** The top value (min Y) of the Rectangle. */
    readonly top: number;
    /** The bottom value (max Y) of the Rectangle. */
    readonly bottom: number;
}
