import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/customer_model.dart';
import 'local/database_helper.dart';
import 'local/tables/customer_table.dart';
import '../../core/errors/exceptions.dart';

abstract class CustomerLocalDataSource {
  /// Gets all customers from the local database
  Future<List<CustomerModel>> getCustomers();
  
  /// Gets a customer by id
  Future<CustomerModel> getCustomerById(String id);
  
  /// Creates a new customer in the database
  Future<CustomerModel> createCustomer(CustomerModel customer);
  
  /// Updates an existing customer in the database
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  
  /// Deletes a customer from the database
  Future<bool> deleteCustomer(String id);
  
  /// Searches customers by name, email or phone
  Future<List<CustomerModel>> searchCustomers(String query);
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  final DatabaseHelper dbHelper;
  final uuid = const Uuid();

  CustomerLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<List<CustomerModel>> getCustomers() async {
    try {
      final db = await dbHelper.database;
      final customersData = await db.query(
        CustomerTable.tableName,
        orderBy: '${CustomerTable.columnName} ASC',
      );

      return customersData.map((map) => CustomerModel.fromMap(map)).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get customers: ${e.toString()}');
    }
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final db = await dbHelper.database;
      final result = await db.query(
        CustomerTable.tableName,
        where: '${CustomerTable.columnId} = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        throw NotFoundException('Customer with id $id not found');
      }

      return CustomerModel.fromMap(result.first);
    } catch (e) {
      if (e is NotFoundException) {
        throw e;
      }
      throw LocalDatabaseException('Failed to get customer: ${e.toString()}');
    }
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final db = await dbHelper.database;
      
      // Create a new customer with a generated ID if it doesn't have one
      final CustomerModel newCustomer = customer.id.isEmpty 
          ? CustomerModel(
              id: uuid.v4(),
              name: customer.name,
              email: customer.email,
              phone: customer.phone,
              address: customer.address,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : CustomerModel(
              id: customer.id,
              name: customer.name,
              email: customer.email,
              phone: customer.phone,
              address: customer.address,
              createdAt: customer.createdAt,
              updatedAt: DateTime.now(),
            );

      await db.insert(
        CustomerTable.tableName,
        newCustomer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return newCustomer;
    } catch (e) {
      throw LocalDatabaseException('Failed to create customer: ${e.toString()}');
    }
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final db = await dbHelper.database;
      
      // Update the customer with the current time
      final updatedCustomer = CustomerModel(
        id: customer.id,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        address: customer.address,
        createdAt: customer.createdAt,
        updatedAt: DateTime.now(),
      );
      
      final count = await db.update(
        CustomerTable.tableName,
        updatedCustomer.toMap(),
        where: '${CustomerTable.columnId} = ?',
        whereArgs: [customer.id],
      );

      if (count == 0) {
        throw NotFoundException('Customer with id ${customer.id} not found');
      }

      return updatedCustomer;
    } catch (e) {
      if (e is NotFoundException) {
        throw e;
      }
      throw LocalDatabaseException('Failed to update customer: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteCustomer(String id) async {
    try {
      final db = await dbHelper.database;
      
      final count = await db.delete(
        CustomerTable.tableName,
        where: '${CustomerTable.columnId} = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw NotFoundException('Customer with id $id not found');
      }

      return true;
    } catch (e) {
      if (e is NotFoundException) {
        throw e;
      }
      throw LocalDatabaseException('Failed to delete customer: ${e.toString()}');
    }
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final db = await dbHelper.database;
      final searchPattern = '%$query%';
      
      final customersData = await db.query(
        CustomerTable.tableName,
        where: '${CustomerTable.columnName} LIKE ? OR ${CustomerTable.columnEmail} LIKE ? OR ${CustomerTable.columnPhone} LIKE ?',
        whereArgs: [searchPattern, searchPattern, searchPattern],
        orderBy: '${CustomerTable.columnName} ASC',
      );

      return customersData.map((map) => CustomerModel.fromMap(map)).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to search customers: ${e.toString()}');
    }
  }
}
