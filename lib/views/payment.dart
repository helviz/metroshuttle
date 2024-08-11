import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import '../widgets/green_intro_widget.dart';
class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            greenIntroWidgetWithoutLogos(title: 'Choose a payment method'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MobileMoneyPayment()),
                    );
                  },
                  child: Text('Mobile Money'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreditCardPayment()),
                    );
                  },
                  child: Text('Credit Card'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MobileMoneyPayment extends StatefulWidget {
  @override
  _MobileMoneyPaymentState createState() => _MobileMoneyPaymentState();
}

class _MobileMoneyPaymentState extends State<MobileMoneyPayment> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Money Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            greenIntroWidgetWithoutLogos(title: 'Mobile Money Payment'),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                    onSaved: (value) => _phoneNumber = value!,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Process mobile money payment here
                        print('Mobile money payment processed');
                      }
                    },
                    child: Text('Pay with Mobile Money'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreditCardPayment extends StatefulWidget {
  @override
  _CreditCardPaymentState createState() => _CreditCardPaymentState();
}

class _CreditCardPaymentState extends State<CreditCardPayment> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Card Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            greenIntroWidgetWithoutLogos(title: 'Credit Card Payment'),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CreditCardWidget(
                    cardNumber: _cardNumber,
                    expiryDate: _expiryDate,
                    cvvCode: _cvv,
                    showBackView: false,
                    cardHolderName: '',
                    onCreditCardWidgetChange: (CreditCardBrand) {},
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your card number';
                      }
                      return null;
                    },
                    onSaved: (value) => _cardNumber = value!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your expiry date';
                      }
                      return null;
                    },
                    onSaved: (value) => _expiryDate = value!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your CVV';
                      }
                      return null;
                    },
                    onSaved: (value) => _cvv = value!,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Process credit card
                        print('Credit card payment processed');
                      }}, child: Text('Pay with credit card'),
                      )
                    ]))])));}}