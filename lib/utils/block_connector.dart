import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mediblock/secret.dart';
import 'package:web3dart/web3dart.dart';

const WALLET_ADDRESS = '0xB152cEec2D0eE75f62f07472cfb66b57aBC9dA33';
const CONTRACT_ADDRESS = '0x36A0636283A2B6bEE84f5c04a4402159Aa830782';
const INFURA_URL = 'https://rinkeby.infura.io/v3/c11a3fb1e66e4a21889bd39dd4948670';

class BlockConnector {
  Client httpClient;
  Web3Client etherClient;
  TransactionInformation information;

  // Test wallet address created from Rinkeby
  final walletAddress = WALLET_ADDRESS;

  initializeClient() {
    httpClient = Client();
    etherClient = Web3Client(INFURA_URL, httpClient);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('assets/abi.json');

    // Use the deployed contract address here (available on Remix IDE)
    String contractAddress = CONTRACT_ADDRESS;

    final contract = DeployedContract(
        ContractAbi.fromJson(abi, 'DataStorage'), EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String functionName) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);

    final result = await etherClient.call(contract: contract, function: ethFunction, params: []);

    return result;
  }

  Future<String> getData(String targetAddress) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddress);

    List<dynamic> result = await query('get');

    return result[0].toString();

    // setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(Secret.privateKey);

    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await etherClient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: args,
          maxGas: 10000000,
          gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 100),
        ),
        fetchChainIdFromNetworkId: true);

    return result;
  }

  Future<String> sendData(List<BigInt> data) async {
    // List<BigInt> randomData = List(400);

    // for (int i = 0; i < 400; i++) {
    //   randomData[i] = BigInt.from(int.parse(valueController.text));
    // }

    // print('Data to be sent: $randomData');

    var response = await submit('set', [data]);

    print('Stored');
    if (response != null) await getTransactionDetails(response);

    // setState(() {
    //   currentTxHash = response;
    // });

    return response;
  }

  Future<String> getWalletBalance() async {
    EthereumAddress address = EthereumAddress.fromHex(walletAddress);
    final walletBalance = await etherClient.getBalance(address);

    print('Wallet Balance: $walletBalance');
    // print('Recent Block (hash): ${await etherClient.getBlockNumber()}');
    print('Gas Price / unit: ${await etherClient.getGasPrice()}');

    // setState(() {
    //   _walletBalance = (walletBalance.getInWei.toDouble() / pow(10, 18)).toStringAsFixed(4);
    // });

    return (walletBalance.getInWei.toDouble() / pow(10, 18)).toStringAsFixed(4);
  }

  Future<TransactionInformation> getTransactionDetails(String txhash) async {
    // setState(() {
    //   retrievingTx = true;
    // });
    information = await etherClient?.getTransactionByHash(txhash);
    // setState(() {});

    // print('----------------');

    if (information != null) {
      // print('Trnx hash: ${information.hash}, ');
      // print('Block hash: ${information?.blockHash}, ');
      // print('Block number: ${information.blockNumber}, ');
      // print('From: ${information.from}, ');
      // print('To: ${information.to ?? 'none (own contract)'}, ');
      // print('Data: ${information.input ?? ''}, ');
      // print('Gas limit: ${information.gas} wei');

      // getTransactionReceipt(txhash);
    }
    // setState(() {
    //   retrievingTx = false;
    // });

    return information;
  }

  Future<TransactionReceipt> getTransactionReceipt(String txhash) async {
    TransactionReceipt receipt = await etherClient.getTransactionReceipt(txhash);

    // if (receipt != null) {
    //   controller.add(receipt);
    //   print('Receipt: Cumulitive gas used: ${receipt.cumulativeGasUsed} wei, ');
    //   print('Receipt: Gas used: ${receipt.gasUsed} wei, ');
    //   print('Receipt: Status: ${receipt.status}');
    // }

    return receipt;
  }

  List<int> sanitizeData(Uint8List rawData) {
    const int BUFFER = 4;
    const int WORD_LENGTH = 32;

    if (rawData != null) {
      int dataLength = (rawData.length - BUFFER) ~/ WORD_LENGTH;

      List<int> sanitizedData = List(dataLength);

      int count = 0;

      for (int i = BUFFER + WORD_LENGTH - 1; i <= rawData.length; i += WORD_LENGTH) {
        sanitizedData[count] = rawData.elementAt(i);
        count++;
      }
      return sanitizedData;
    }

    return null;

    // print(sanitizedData.length);
  }
}
