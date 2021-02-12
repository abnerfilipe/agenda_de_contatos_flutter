import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:agenda_de_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];
  @override
  void initState() {
    super.initState();
    // Contact c = new Contact();
    // c.name = "Filipe Abner";
    // c.email = "filipeabnersantos@gmail.com";
    // c.phone = "993907870";
    // c.img = null;
    // helper.saveContact(c);
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem(
                child: Text("Ordenar: A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem(
                child: Text("Ordenar: Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, contacts[index]);
        },
        padding: EdgeInsets.all(10.0),
      ),
    );
  }

  Widget _contactCard(BuildContext context, Contact contact) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contact.img != null
                        ? FileImage(File(contact.img))
                        : AssetImage("lib/images/person.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width * 0.6),
                      child: Text(
                        contact.name ?? "",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width * 0.6),
                      child: Text(
                        contact.email ?? "",
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width * 0.6),
                      child: Text(
                        contact.phone ?? "",
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () => {
        // _showContactPage(contact: contact),
        _showOptions(context, contact),
      },
    );
  }

  void _showOptions(BuildContext context, Contact contact) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(onClosing: () {
            Navigator.pop(context);
          }, builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: TextButton(
                      child: Text(
                        "Ligar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        launch("tel:${contact.phone}");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: TextButton(
                      child: Text(
                        "Editar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contact);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: TextButton(
                      child: Text(
                        "Excluir",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        helper.deleteContact(contact.id);
                        setState(() {
                          contacts.remove(contact);
                          _getAllContacts();
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contact,
        ),
      ),
    );
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) => {
          setState(() {
            contacts = list;
          })
        });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
