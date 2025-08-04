import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async'; // Para Future e async/await
import 'package:menu_digital/models/menu_item.dart';
import 'package:menu_digital/models/order.dart';

class DatabaseHelper {
  static Database? _database; // Instância do banco de dados
  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor(); // Singleton

  DatabaseHelper._privateConstructor();

  // Getter para o banco de dados. Se não existir, inicializa.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Inicializa o banco de dados.
  Future<Database> _initDb() async {
    String path = join(
      await getDatabasesPath(),
      'menu_digital_app.db',
    ); // Define o caminho do DB
    return await openDatabase(
      path,
      version: 2, // A versão continua 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Cria as tabelas do banco de dados.
  Future _onCreate(Database db, int version) async {
    // Tabela de itens do cardápio com o novo campo imagePath
    await db.execute('''
      CREATE TABLE menu_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        imagePath TEXT NOT NULL 
      )
    ''');
    // Tabela de pedidos
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menuItemId INTEGER NOT NULL,
        menuItemName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL, 
        timestamp TEXT NOT NULL,
        isBilled INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (menuItemId) REFERENCES menu_items (id) ON DELETE CASCADE
      )
    ''');

    // Popula o cardápio com itens iniciais, agora com imagePath
    await _populateInitialData(db);
  }

  // Lida com atualização de versão do DB
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute("DROP TABLE IF EXISTS orders");
      await db.execute("DROP TABLE IF EXISTS menu_items");
      await _onCreate(db, newVersion);
    }
  }

  // Método para popular os dados iniciais com os caminhos dos assets
  Future<void> _populateInitialData(Database db) async {
    await db.insert(
      'menu_items',
      MenuItem(
        name: 'Café Expresso',
        description: 'Café forte e encorpado.',
        price: 5.00,
        category: 'Bebidas',
        imagePath: 'assets/images/cafe_expresso.jpg',
      ).toMap(),
    );
    await db.insert(
      'menu_items',
      MenuItem(
        name: 'Cappuccino',
        description: 'Café com leite vaporizado e espuma.',
        price: 8.50,
        category: 'Bebidas',
        imagePath: 'assets/images/cappuccino.jpg',
      ).toMap(),
    );
    await db.insert(
      'menu_items',
      MenuItem(
        name: 'Pão de Queijo',
        description: 'Tradicional pão de queijo mineiro.',
        price: 4.00,
        category: 'Comidas',
        imagePath: 'assets/images/pao_de_queijo.jpg',
      ).toMap(),
    );
    await db.insert(
      'menu_items',
      MenuItem(
        name: 'Bolo de Chocolate',
        description: 'Fatia de bolo de chocolate com cobertura.',
        price: 12.00,
        category: 'Doces',
        imagePath: 'assets/images/bolo_de_chocolate.jpg',
      ).toMap(),
    );
    await db.insert(
      'menu_items',
      MenuItem(
        name: 'Suco de Laranja',
        description: 'Suco natural de laranja.',
        price: 7.00,
        category: 'Bebidas',
        imagePath: 'assets/images/suco_de_laranja.jpg',
      ).toMap(),
    );
  }

  Future<List<MenuItem>> getMenuItems() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('menu_items');
    return List.generate(maps.length, (i) {
      return MenuItem.fromMap(maps[i]);
    });
  }

  // --- Operações CRUD para Order ---
  Future<void> insertOrdersBatch(List<Order> orders) async {
    final db = await instance.database;
    final batch = db.batch();
    for (final order in orders) {
      batch.insert('orders', order.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Order>> getOrders({bool? isBilled}) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (isBilled != null) {
      maps = await db.query(
        'orders',
        where: 'isBilled = ?',
        whereArgs: [isBilled ? 1 : 0],
      );
    } else {
      maps = await db.query('orders');
    }
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<int> updateOrdersToBilled(List<Order> orders) async {
    Database db = await instance.database;
    int count = 0;
    for (Order order in orders) {
      order.isBilled = true;
      count += await db.update(
        'orders',
        order.toMap(),
        where: 'id = ?',
        whereArgs: [order.id],
      );
    }
    return count;
  }

  Future<int> deleteOrder(int id) async {
    Database db = await instance.database;
    return await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllOrders() async {
    Database db = await instance.database;
    await db.delete('orders');
  }
}
