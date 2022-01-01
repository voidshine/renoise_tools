// Warning: Not ALL uses of LuaIndex are yet covered. In particular, functions that *return* a LuaIndex don't get automatic shifting yet.

// This transforms a TypeScript AST to automatically converts to and from Lua one-based index values and normal zero-based index values.

// Note: generator functions don't work at all in this context, seemingly because of
//  how tstl uses ts-node option transpileOnly. Other features appear to be missing
//  as well, because some portions of this code don't even get type checked.

import * as ts from 'typescript'

// const log = console.log;
const log = (..._: any[]) => {};

function locate(node: ts.Node) {
    const file = node.getSourceFile();
    const from = ts.getLineAndCharacterOfPosition(file, node.pos);
    const to = ts.getLineAndCharacterOfPosition(file, node.end);
    if (from.line == to.line) {
        return `${file.fileName}:${from.line + 1},${from.character + 1}-${to.character + 1}`;
    } else {
        return `${file.fileName}:(${from.line + 1},${from.character + 1})-(${to.line + 1},${to.character + 1})`;
    }
}

function hasRenoiseSource(declaration: ts.Declaration) {
    return declaration.getSourceFile().fileName.match("renoise_types");
}

function nameHasIndex(name: string): boolean {
    return !!name.match("index");
}

const transformerProgram = (program: ts.Program) => {
    const typeChecker = program.getTypeChecker();
    let indent = 0;

    function isLuaIndexDecl(decl: ts.Declaration) {
        return !!decl?.getText().match("LuaIndex");
    }
    function isLuaIndex(symbol: ts.Symbol) {
        if (!symbol) { return false; }
        // if (symbol.name == "start_track") {
        //     // const s = typeChecker.getDeclaredTypeOfSymbol(symbol);
        //     const s = typeChecker.getTypeOfSymbolAtLocation(symbol, symbol.valueDeclaration.parent);
        //     // console.log("AS:", s, "AS name:", s.name);
        //     log("**", s, symbol.valueDeclaration.getText());
        // }
        if (symbol.members != null) {
            // Don't check huge class declarations, etc.
            return false;
        }

        log("***", symbol.valueDeclaration?.getText());

        // typeChecker.getSignat(symbol.valueDeclaration)
        // const t = typeChecker.getDeclaredTypeOfSymbol(symbol);
        // t.getCallSignatures().forEach(signature => {
        //     log("!!!SIG", signature);
        // });

        // TODO: This is not a good hack. Maybe other methods DID work?
        return isLuaIndexDecl(symbol.valueDeclaration);

        //return typeChecker.getDeclaredTypeOfSymbol(symbol).getSymbol()?.name == "LuaIndex";
        // typeChecker.getDeclaredTypeOfSymbol(symbol).getSymbol()?
    }

    // From TypeScript docs: "A property decorator cannot be used in a declaration file, or in any other ambient context (such as in a declare class)."
    // So...decorators seem to be a non-option for the ambient type declaration interfaces. :/
    function hasTypeWithShift(symbol: ts.Symbol) {
        // return true;
        //return nameHasIndex(symbol.name) && hasRenoiseSource(symbol.valueDeclaration);
        return isLuaIndex(symbol);
    }

    const transformerFactory: ts.TransformerFactory<ts.SourceFile> = context => {
        return sourceFile => {
            const visitor = (node: ts.Node): ts.Node => {
                log(`${' '.repeat(indent)}${ts.SyntaxKind[node.kind]}(${node.kind}) @ ${locate(node)}`);

                // TODO: This kind of property assignment isn't working because it's on
                //  an object literal where the declaration actually happens; it doesn't trace
                //  back to a type declaration, e.g. on the interface like renoise.PatternSelection.
                // Check for property assignment in the form { property: value }
                // if (ts.isPropertyAssignment(node)) {
                //     if (hasTypeWithShift(typeChecker.getSymbolAtLocation(node.name))) {
                //         log("Property assignment +1 @", locate(node));
                //         const initializer = ts.createBinary(ts.visitNode(node.initializer, visitor), ts.SyntaxKind.PlusToken, ts.createNumericLiteral("1"));
                //         initializer.parent = node;
                //         return ts.updatePropertyAssignment(node, node.name, initializer);
                //     }
                // }

                // return ts.visitEachChild(node, visitor, context);

                // Check for assignment to an index property, in the form <property_access> = <value>
                if (ts.isBinaryExpression(node)) {
                    const c0 = node.getChildAt(0);
                    if (ts.isPropertyAccessExpression(c0) && node.operatorToken.kind == ts.SyntaxKind.EqualsToken) {
                        // TODO: What if user aliases the symbol?
                        if (hasTypeWithShift(typeChecker.getSymbolAtLocation(c0))) {
                            log("Property access assignment +1 @", locate(node));
                            const right = ts.createBinary(ts.visitNode(node.right, visitor), ts.SyntaxKind.PlusToken, ts.createNumericLiteral("1"));
                            right.parent = node;
                            // Note, not visiting left, thus avoiding get-accessor shift.
                            return ts.updateBinary(node, node.left, right, node.operatorToken);
                        }
                    }
                }

                // return ts.visitEachChild(node, visitor, context);

                // Check for calls with parameters that take an index parameter.
                if (ts.isCallExpression(node)) {
                    log(locate(node));

                    const signature = typeChecker.getResolvedSignature(node);
                    log("rts:",signature.getReturnType().getSymbol()?.name);
                    if (signature.parameters.some(isLuaIndex)) {
                        const newArgs = node.arguments.map((arg, i) => {
                            const parameter = signature.parameters[i];

                            // TODO: Why does the declared type of parameter symbol produce error? type LuaIndex = number ... so it doesn't really have a new type?? Use text of declaration for now.
                            // log("parm",typeChecker.getDeclaredTypeOfSymbol(parameter));
                            //log("parm", parameter.valueDeclaration.getText());

                            if (isLuaIndex(parameter)) {
                                log("Method parameter +1 @", locate(node));
                                const binary = ts.createBinary(ts.visitNode(arg, visitor), ts.SyntaxKind.PlusToken, ts.createNumericLiteral("1"));;
                                binary.parent = node;
                                return binary;
                            } else {
                                return ts.visitNode(arg, visitor);
                            }
                        });
                        return ts.updateCall(node, ts.visitNode(node.expression, visitor), node.typeArguments, newArgs);
                    }

                    // TODO: May shift result of call if return type is LuaIndex!
                }

                // return ts.visitEachChild(node, visitor, context);

                // Check for get access to index property.
                if (ts.isPropertyAccessExpression(node)) {
                    const symbol = typeChecker.getSymbolAtLocation(node);
                    // const typ = typeChecker.getTypeOfSymbolAtLocation(symbol, node);
                    const typ = typeChecker.getTypeAtLocation(node);
                    // Make sure type is not a method/call type; we are only accessing the property at this point.
                    if (typ.getCallSignatures().length == 0) {
                        if (hasTypeWithShift(symbol)) {        
                            log("Property get access -1 @", node.getText(), locate(node));
                            const binary = ts.createBinary(node, ts.SyntaxKind.MinusToken, ts.createNumericLiteral("1"));
                            // binary.parent = node.parent;
                            return binary;
                        }
                    }
                }

                // return ts.visitEachChild(node, visitor, context);

                if (ts.isBlock(node)) {
                    if (ts.isFunctionLike(node.parent)) {
                        if (node.parent.parameters.some(isLuaIndexDecl)) {
                            const adjustParameters = [];
                            node.parent.parameters.forEach(p => {
                                if (isLuaIndexDecl(p)) {
                                    const id = ts.createIdentifier(p.name.getText());
                                    // tstl falls over if we don't give things parents.
                                    id.parent = node;
                                    const shift = ts.createExpressionStatement(ts.createPostfix(id, ts.SyntaxKind.MinusMinusToken));
                                    shift.parent = node;
                                    adjustParameters.push(shift);
                                }
                            });
                            log("Function-like body shifted LuaIndexParameters:", adjustParameters);
                            return ts.updateBlock(node, [...adjustParameters, ...node.statements]);
                        }
                    }
                }

                indent += 2;
                const result = ts.visitEachChild(node, visitor, context);
                indent -= 2;
                
                return result;
            };

            return ts.visitNode(sourceFile, visitor);
        };
    };

    return transformerFactory;
};
    
export default transformerProgram;
