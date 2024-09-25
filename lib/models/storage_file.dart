class StorageFile {
  final String name;
  final String downloadUrl;
  String filePath;
  final DateTime date;

  StorageFile({
    required this.name,
    required this.downloadUrl,
    required this.filePath,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  @override
  String toString() {
    return 'StorageFile{name: $name, downloadUrl: $downloadUrl, filePath: $filePath}';
  }
}
