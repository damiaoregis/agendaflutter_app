import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contectTable = 'contectTable';
final String idColun = 'idColun';
final String nameColun = 'nameColun';
final String emailColun = 'emailColun';
final String phoneColun = 'phoneColun';
final String imgColun = 'imgColun';

class ContactHelper{

 static final ContactHelper _instance = ContactHelper.internal();

 factory ContactHelper() =>_instance;

 ContactHelper.internal();

 Database _db;

 Future<Database> get db async{
   if(_db != null){
     return _db;
   }else{
     _db = await initDb();
   }
 }
 Future<Database> initDb()async{
   final databasesPath = await getDatabasesPath();
   final path = join(databasesPath, 'contacts.db');
   
  return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion)async{
      await db.execute(
          'CREATE TABLE $contectTable($idColun INTERGER PRIMARY KEY,'
             '$nameColun TEXT, $emailColun TEXT,$phoneColun TEXT, $imgColun TEXT)'
      );
   });
 }
 Future<Contact> saveContact(Contact contact) async{
   Database dbContact = await db;
   contact.id = await dbContact.insert(contectTable, contact.toMap());
   return contact;
 }
 Future<Contact> getContact(int id) async {
   Database dbContact = await db;
   List<Map> maps = await dbContact.query(contectTable,
       columns: [idColun, nameColun, emailColun, phoneColun, imgColun],
       where: '$idColun = ?',
       whereArgs: [id]);
   if (maps.length > 0) {
     return Contact.fromMap(maps.first);
   } else {
     return null;
   }
 }
 Future<int>deleteContact(int id)async{
   Database dbContact = await db;
   return await dbContact.delete(contectTable, where: '$idColun = ?', whereArgs: [id]);
 }
 Future<int>updateContact(Contact contact)async{
   Database dbContact = await db;
   return await dbContact.update(contectTable,
       contact.toMap(),
       where: '$idColun = ?',
       whereArgs: [contact.id]);
 }
 Future<List> getAllContact()async{
   Database dbContact = await db;
   List listMap = await dbContact.rawQuery('SELECT * FROM $contectTable');
   List<Contact> listContect = List();
   for(Map m in listMap){
     listContect.add(Contact.fromMap(m));
   }
   return listContect;
 }
 Future<int> getNumber()async{
   Database dbContact = await db;
   return Sqflite.firstIntValue(await dbContact.rawQuery('SELECT COUNT(*) FROM $contectTable'));
 }
 Future close()async{
   Database dbContact = await db;
   dbContact.close();
 }
}

class Contact{
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map){
    id = map[idColun];
    name = map[nameColun];
    email = map[emailColun];
    phone = map[phoneColun];
    img = map[imgColun];

  }
  Map toMap(){
    Map<String, dynamic> map ={
     nameColun: name,
     emailColun:  email,
     phoneColun: phone,
     imgColun: img,
    };
    if(id != null){
      map[idColun] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Contect(id: $id, name:$name, email:$email, phone: $phone, img: $img)';
  }
}
