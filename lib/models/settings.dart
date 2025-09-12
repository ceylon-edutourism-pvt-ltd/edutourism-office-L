class AppSettings {
  String logoPath;
  String outputDirectory;
  bool bulkModeEnabled;
  double logoPositionX;
  double logoPositionY;
  double logoWidth;
  double logoHeight;
  String libreOfficeCommand;

  AppSettings({
    this.logoPath = '',
    this.outputDirectory = '',
    this.bulkModeEnabled = false,
    this.logoPositionX = 50,
    this.logoPositionY = 50,
    this.logoWidth = 150,
    this.logoHeight = 150,
    this.libreOfficeCommand = 'soffice',
  });
}
