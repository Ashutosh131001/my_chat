import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:my_chat/viewmodels/staredmessageveiwmodel.dart';

class stared extends StatelessWidget {
  const stared({super.key});

  @override
  Widget build(BuildContext context) {
    final Staredmessageveiwmodel vm = Get.put(Staredmessageveiwmodel());
    return Scaffold(
      appBar: AppBar(title: Text('stared message')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: vm.streamStarredMessages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Something went wrong while loading messages",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                }
                if (snapshot.connectionState == ConnectionState.waiting)
                  return CircularProgressIndicator();
                List<Map<String, dynamic>> data = snapshot.data!.docs
                    .map((e) => e.data())
                    .toList();
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: Text(data[i]['senderId'] ?? ''),
                      subtitle: Text(data[i]['text'] ?? ''),
                      trailing: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                          data[i]['timestamp'],
                        ).toLocal().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
