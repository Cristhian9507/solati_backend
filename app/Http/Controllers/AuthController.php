<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
  public function registro(Request $request)
  {

    $rules =  [
      'name' => 'required',
      'email' => 'required|email|unique:users',
      'password' => 'required',
      'identificacion' => 'required|numeric|unique:users',
    ];

    $messages =  [
      'required' => 'El :attribute es un campo obligatorio.',
      'email' => 'El :attribute debe de ser un email valido.',
      'unique' => 'El :attribute que ingresaste ya se encuentra registrado en el sistema.'
    ];

    $attributes =
      [
        'name' => 'Nombre',
        'email' => 'Email',
        'password' => 'Contraseña',
        'identificacion' => 'Número de Identificación'
      ];


    $validator = Validator::make($request->all(),$rules, $messages, $attributes);

    $errors = $validator->errors();

    if($validator->fails())
    {
      return response()->json(['status_code' => 400, 'mensaje' => $errors->all()[0]]);
    }

    $user = new User();
    $user->name = strtolower($request->name);
    $user->email = strtolower($request->email);
    $user->password = bcrypt($request->password);
    $user->identificacion = $request->identificacion;
    $confirmar = $user->save();

    if($confirmar) {
      return response()->json([
        'status_code' => 200,
        'mensaje' => 'Usuario creado correctamente']
      );
    } else {
      return response()->json([
        'status_code' => 500,
        'mensaje' => 'Ocurrió un error tratando de crear el usuario, por favor contacte al administrador.']
      );
    }
  }

  public function login(Request $request)
  {
    $validator = Validator::make($request->all(), [
      'email' => 'required|email',
      'password' => 'required'
    ]);

    if($validator->fails())
    {
      return response()->json(['status_code' => 401, 'mensaje' => 'Datos erroneos'], 401);
    }

    $credentials = ['email' => strtolower($request->email),'password' => $request->password];

    if(!Auth::attempt($credentials)){
      return response()->json([
        'status_code' => 401,
        'mensaje' => 'Credenciales invalidas',
        'credentials' => $credentials
      ]);
    }

    $user = User::where('email',$request->email)->first();
    $token = $user->createToken('API Token')->plainTextToken;
    return response()->json($user);
  }

  /**
   * Store a newly created resource in storage.
   */
  public function store(Request $request)
  {
    //
  }

  /**
   * Display the specified resource.
   */
  public function show(string $id)
  {
    //
  }

  /**
   * Show the form for editing the specified resource.
   */
  public function edit(string $id)
  {
    //
  }

  /**
   * Update the specified resource in storage.
   */
  public function update(Request $request, string $id)
  {
    //
  }

  /**
   * Remove the specified resource from storage.
   */
  public function destroy(string $id)
  {
    //
  }
}
