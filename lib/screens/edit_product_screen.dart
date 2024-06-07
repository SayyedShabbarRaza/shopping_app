import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/Model.dart';
import 'package:shopping/models/provider.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, this.id = ''});
  final String id;
  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _priceFocusScope = FocusNode();
  final _imageUrlFocusScope = FocusNode();
  final _descriptionFocusScope = FocusNode();
  final _imageUrlController = TextEditingController();
  final form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var isInit = true;
  var isLoading = false;
  var initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusScope.addListener(updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      if (widget.id.isNotEmpty) {
        final p =
            Provider.of<Providerr>(context, listen: false).findById(widget.id);
        _editedProduct = p;
        initValues = {
          'title': p.title,
          'description': p.description,
          'price': p.price.toString(),
          'imageUrl': p.imageUrl,
        };
        _imageUrlController.text = p.imageUrl;
      }
      isInit = false;
    }
    super.didChangeDependencies();
  }

  void updateImageUrl() {
    if (!_imageUrlFocusScope.hasFocus) {
      if (!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https')) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageUrlFocusScope.removeListener(updateImageUrl);
    _priceFocusScope.dispose();
    _imageUrlFocusScope.dispose();
    _imageUrlController.dispose();
    _descriptionFocusScope.dispose();
    super.dispose();
  }
Future<void> submit() async {
  final isValid = form.currentState!.validate();
  if (!isValid) {
    return;
  }
  form.currentState!.save();
  setState(() {
    isLoading = true;
  });

  final provid = Provider.of<Providerr>(context, listen: false);

  try {
    if (_editedProduct.id.isEmpty) {
      await provid.add(_editedProduct);
    } else {
      provid.updateProduct(_editedProduct.id, _editedProduct);
    }
    Navigator.of(context).pop();
  } catch (error) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:const Text('An error occurred'),
        content:const Text('Something went wrong.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Items'),
        actions: [
          IconButton(
            onPressed: submit,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: initValues['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusScope);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value.toString(),
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Title can\'t be empty';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: initValues['price'],
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusScope,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusScope);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value.toString()),
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Price can\'t be empty';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: initValues['description'],
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusScope,
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: value.toString(),
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Description can\'t be empty';
                        }
                        if (value.length < 10) {
                          return 'Description should be at least 10 characters long';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.amber),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      );
                                    },
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusScope,
                            onFieldSubmitted: (_) {
                              submit();
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value.toString(),
                              );
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Image URL can\'t be empty';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL';
                              }
                              // if (!value.endsWith('.png') &&
                              //     !value.endsWith('.jpg') &&
                              //     !value.endsWith('.jpeg')) {
                              //   return 'Please enter a valid image URL';
                              // }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
