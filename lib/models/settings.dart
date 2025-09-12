class AppSettings {
  String logoPath;
  String signaturePath;  // Added signature path
  String outputDirectory;
  bool bulkModeEnabled;
  double logoPositionX;
  double logoPositionY;
  double logoWidth;
  double logoHeight;

  AppSettings({
    this.logoPath = '',
    this.signaturePath = '',  // Added signature path
    this.outputDirectory = '',
    this.bulkModeEnabled = false,
    this.logoPositionX = 50,
    this.logoPositionY = 50,
    this.logoWidth = 150,
    this.logoHeight = 150,
  });
}