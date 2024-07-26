
import Foundation

/// Represents the style configuration for the progress bar.
public struct ProgressBarStyle {
    /// Defines the format of the progress bar.
    public enum BarFormat {
        case standard
        case simple
        case custom(String)

        var format: String {
            switch self {
            case .standard:
                return "{l_bar}{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}, {rate_fmt}{postfix}]"
            case .simple:
                return "{l_bar}{bar}| {percentage:3.0f}%"
            case let .custom(format):
                return format
            }
        }
    }

    /// Defines the available colors for the progress bar.
    public enum Color: String {
        case black = "\u{001B}[30m"
        case red = "\u{001B}[31m"
        case green = "\u{001B}[32m"
        case yellow = "\u{001B}[33m"
        case blue = "\u{001B}[34m"
        case magenta = "\u{001B}[35m"
        case cyan = "\u{001B}[36m"
        case white = "\u{001B}[37m"
        case reset = "\u{001B}[0m"
    }

    /// The format of the progress bar.
    public var barFormat: BarFormat
    /// The separator between the percentage and the progress bar.
    public var barSeparator: String
    /// The left bracket of the progress bar.
    public var leftBracket: String
    /// The right bracket of the progress bar.
    public var rightBracket: String
    /// The character used for the empty part of the progress bar.
    public var emptyFill: String
    /// The character used for the filled part of the progress bar.
    public var fill: String
    /// The width of the progress bar. If nil, a default width is used.
    public var ncols: Int?
    /// The scale factor for the progress units.
    public var unitScale: Double
    /// The divisor for the progress units.
    public var unitDivisor: Double
    /// The color of the progress bar.
    public var barColor: Color?
    /// The color of the description text.
    public var descColor: Color?

    /// The default style for the progress bar.
    public static let `default` = ProgressBarStyle(
        barFormat: .standard,
        barSeparator: " ",
        leftBracket: "[",
        rightBracket: "]",
        emptyFill: "░",
        fill: "█",
        ncols: nil,
        unitScale: 1.0,
        unitDivisor: 1.0,
        barColor: nil,
        descColor: nil
    )

    /// Initializes a new ProgressBarStyle instance.
    public init(
        barFormat: BarFormat = .standard,
        barSeparator: String = " ",
        leftBracket: String = "[",
        rightBracket: String = "]",
        emptyFill: String = "░",
        fill: String = "█",
        ncols: Int? = nil,
        unitScale: Double = 1.0,
        unitDivisor: Double = 1.0,
        barColor: Color? = nil,
        descColor: Color? = nil
    ) {
        self.barFormat = barFormat
        self.barSeparator = barSeparator
        self.leftBracket = leftBracket
        self.rightBracket = rightBracket
        self.emptyFill = emptyFill
        self.fill = fill
        self.ncols = ncols
        self.unitScale = unitScale
        self.unitDivisor = unitDivisor
        self.barColor = barColor
        self.descColor = descColor
    }
}
