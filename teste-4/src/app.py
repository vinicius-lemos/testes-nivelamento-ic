from flask import Flask, jsonify, request
from flask_cors import CORS
from flaskext.mysql import MySQL # type: ignore
import pymysql

app = Flask(__name__)

mysql = MySQL()

app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = '2703705'
app.config['MYSQL_DATABASE_DB'] = 'ans_data'
app.config['MYSQL_DATABASE_HOST'] = '127.0.0.1'

mysql.init_app(app)

CORS(app)

@app.route('/search', methods=['GET'])
def search():
  connection = mysql.connect()
  cursor = connection.cursor(pymysql.cursors.DictCursor)

  parameter = request.args.get('term', '')

  try:
    columns = ['bairro', 'cargo_representante', 'cep', 'cidade', 'cnpj', 'complemento', 'data_registro_ans', 'ddd', 'endereco_eletronico', 'fax', 'logradouro', 'modalidade', 'nome_fantasia', 'numero', 'razao_social', 'regiao_de_comercializacao', 'registro_ans', 'representante', 'telefone', 'uf']
    columns_concat = ', '.join(columns)
    
    query = f'SELECT * FROM dados_operadoras WHERE CONCAT({columns_concat}) LIKE "%{parameter}%" LIMIT 10'

    cursor.execute(query)
    operators_list = cursor.fetchall()
    return jsonify({
      'status': 'sucess',
      'operators': operators_list
    })
  except Exception as e:
    print(e)
  finally:
    cursor.close()
    connection.close()

if __name__ == '__main__':
  app.run(debug=True)