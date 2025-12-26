class YearFormatter {
  /// Formats a year for display, handling BC/AD and large numbers
  /// Negative years are BC, positive years are AD
  /// Years within ±9999 are shown as full years, outside that range use K/M notation
  static String format(int year) {
    if (year < 0) {
      // BC years
      final absYear = year.abs();
      if (absYear >= 1000000) {
        // Millions
        final millions = (absYear / 1000000).toStringAsFixed(1);
        final cleanMillions = millions.endsWith('.0') 
            ? millions.substring(0, millions.length - 2) 
            : millions;
        return '${cleanMillions}M BC';
      } else if (absYear >= 10000) {
        // Thousands (only for >= 10K)
        final thousands = (absYear / 1000).toStringAsFixed(1);
        final cleanThousands = thousands.endsWith('.0') 
            ? thousands.substring(0, thousands.length - 2) 
            : thousands;
        return '${cleanThousands}K BC';
      } else {
        return '$absYear BC';
      }
    } else if (year == 0) {
      return '1 AD';
    } else {
      // AD years
      if (year >= 1000000) {
        // Millions
        final millions = (year / 1000000).toStringAsFixed(1);
        final cleanMillions = millions.endsWith('.0') 
            ? millions.substring(0, millions.length - 2) 
            : millions;
        return '${cleanMillions}M AD';
      } else if (year >= 10000) {
        // Thousands (only for >= 10K)
        final thousands = (year / 1000).toStringAsFixed(1);
        final cleanThousands = thousands.endsWith('.0') 
            ? thousands.substring(0, thousands.length - 2) 
            : thousands;
        return '${cleanThousands}K AD';
      } else {
        return '$year AD';
      }
    }
  }

  /// Formats a year for display in a compact badge format
  /// Years within ±9999 are shown as full years, outside that range use K/M notation
  static String formatCompact(int year) {
    if (year < 0) {
      final absYear = year.abs();
      if (absYear >= 1000000) {
        final millions = (absYear / 1000000).toStringAsFixed(1);
        // Remove trailing .0 for whole numbers
        final cleanMillions = millions.endsWith('.0') 
            ? millions.substring(0, millions.length - 2) 
            : millions;
        return '${cleanMillions}M BC';
      } else if (absYear >= 10000) {
        // Thousands (only for >= 10K)
        final thousands = (absYear / 1000).toStringAsFixed(0);
        return '${thousands}K BC';
      } else {
        return '$absYear BC';
      }
    } else if (year == 0) {
      return '1 AD';
    } else {
      if (year >= 1000000) {
        final millions = (year / 1000000).toStringAsFixed(1);
        // Remove trailing .0 for whole numbers
        final cleanMillions = millions.endsWith('.0') 
            ? millions.substring(0, millions.length - 2) 
            : millions;
        return '${cleanMillions}M AD';
      } else if (year >= 10000) {
        // Thousands (only for >= 10K)
        final thousands = (year / 1000).toStringAsFixed(0);
        return '${thousands}K AD';
      } else {
        return '$year';
      }
    }
  }
}

