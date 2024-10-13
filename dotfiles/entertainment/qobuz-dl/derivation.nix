{ lib
, buildPythonPackage
, fetchPypi

  # build-system
, setuptools-scm

  # dependencies
, attrs
, pluggy
, py
, setuptools
, six

  # buildInputs
, python3Packages
}:
with python3Packages;
buildPythonPackage rec {
  pname = "qobuz-dl";
  version = "0.9.9.10";
  pyproject = false;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-q7TUl3scg+isoLB0xJvJLCtvJU7O+ogMlftt0O73qb4=";
  };

  # postPatch = ''
  #  # don't test bash builtins
  #  rm testing/test_argcomplete.py
  #'';

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [ attrs py setuptools six pluggy ];

  # nativeCheckInputs = [
  #   hypothesis
  # ];

  meta = with lib; {
    name = "qobuz-dl";
    description = "Framework for writing tests";
    homepage = "https://github.com/vitiko98/qobuz-dl";
    license = licenses.gpl3;
    maintainers = with maintainers; [ mjwcodr ];
  };
}
