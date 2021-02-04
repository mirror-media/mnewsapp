abstract class ConfigRepos {
  Future<bool> loadTheConfig();
}

class ConfigServices implements ConfigRepos{
  @override
  Future<bool> loadTheConfig() async{
    await Future.delayed(Duration(seconds: 2));
    return true;
  }
}