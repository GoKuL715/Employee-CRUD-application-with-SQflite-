import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allEmployees = [];
  bool _isLoading = true;

  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dateOfJoiningController = TextEditingController();

  void _refreshData() async {
    final employees = await SQLHelper.getAllEmployees();
    setState(() {
      _allEmployees = employees;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _addEmployee() async {
    await SQLHelper.createEmployee(
      int.parse(_employeeIdController.text),
      _employeeNameController.text,
      _genderController.text,
      _dateOfJoiningController.text,
    );
    _refreshData();
  }

  Future<void> _updateEmployee(int id) async {
    await SQLHelper.updateEmployee(
      id,
      int.parse(_employeeIdController.text),
      _employeeNameController.text,
      _genderController.text,
      _dateOfJoiningController.text,
    );
    _refreshData();
  }

  void _deleteEmployee(int id) async {
    await SQLHelper.deleteEmployee(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Employee Deleted"),
    ));
    _refreshData();
  }

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingEmployee = _allEmployees.firstWhere(
        (element) => element['id'] == id,
      );

      if (existingEmployee != null) {
        _employeeIdController.text = existingEmployee['employeeId'].toString();
        _employeeNameController.text = existingEmployee['employeeName'];
        _genderController.text = existingEmployee['gender'];
        _dateOfJoiningController.text = existingEmployee['dateOfJoining'];
      }
    }

    showModalBottomSheet(
      elevation: 5,
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 30,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 50,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _employeeIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Employee ID",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _employeeNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Employee Name",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Gender",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dateOfJoiningController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Date of Joining",
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (id == null) {
                      await _addEmployee();
                    } else {
                      await _updateEmployee(id);
                    }
                    _employeeIdController.text = "";
                    _employeeNameController.text = "";
                    _genderController.text = "";
                    _dateOfJoiningController.text = "";

                    Navigator.of(context).pop();
                    print("Employee Added/Updated");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      id == null ? "Add Employee" : "Update",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: const Text("Employee Data"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _allEmployees.length,
                    itemBuilder: (context, index) => Card(
                      margin: const EdgeInsets.all(15),
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            _allEmployees[index]['employeeName'],
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        subtitle: Text("Employee ID: ${_allEmployees[index]['employeeId']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                showBottomSheet(_allEmployees[index]['id']);
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.indigo,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _deleteEmployee(_allEmployees[index]['id']);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 80), // Adding some space at the bottom
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
